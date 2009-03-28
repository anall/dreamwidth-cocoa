#import "DWUser.h"
#import "DWUser+Internal.h"
#import "NSStringAdditions.h"
#import "DWXMLRPCRequest.h"
#import "DWUserpic.h"
#import "DWJournal.h"
#import "DWJournal+Internal.h"

@interface DWJournal ()
@property (nonatomic, retain, readwrite) NSString *username;
@property (readwrite) BOOL inProgress;

@end

@interface DWUser ()
@property (readwrite) BOOL loggedIn;
@property (readwrite) BOOL usernameInvalid;
@property (readwrite) BOOL passwordInvalid;

@property (nonatomic, retain, readwrite) NSNumber *faultCode;
@property (nonatomic, retain, readwrite) NSString *faultString;

@property (nonatomic, retain, readwrite) NSString *fullName;
@property (nonatomic, retain, readwrite) NSDictionary *userpics;
@property (nonatomic, retain, readwrite) DWUserpic *defaultUserpic;
@property (nonatomic, retain, readwrite) NSDictionary *journals;

-(BOOL)parseLoginResponse:(XMLRPCResponse *)response;
-(void)loginRequest:(DWXMLRPCRequest *)req withArg:(id)arg error:(NSError *)error orResponse:(XMLRPCResponse *)resp;
@end

@implementation DWUser
@synthesize md5Password, endpointURL;
@synthesize usernameInvalid, passwordInvalid, loggedIn;
@synthesize faultCode, faultString;
@synthesize fullName, userpics, defaultUserpic, journals;

#pragma mark Public

+(DWUser *)userWithUsername:(NSString *)username andPassword:(NSString *)password {
    return [[[DWUser alloc] initWithUsername:username andHashedPassword:[password md5String]] autorelease];
}

-(id)initWithUsername:(NSString *)_username andPassword:(NSString *)password {
    return [self initWithUsername:_username andHashedPassword:[password md5String]];
}

+(DWUser *)userWithUsername:(NSString *)username andHashedPassword:(NSString *)md5Password {
    return [[[DWUser alloc] initWithUsername:username andHashedPassword:md5Password] autorelease];
}

-(id)initWithUsername:(NSString *)_username andHashedPassword:(NSString *)password {
    self = [super init];
    if (self != nil) {
        self.usernameInvalid = NO;
        self.passwordInvalid = NO;
        self.loggedIn = NO;
        self.inProgress = NO;
        self.endpointURL = [NSURL URLWithString:@"http://www.dreamwidth.org/interface/xmlrpc"];
        
        self.username = _username;
        self.md5Password = password;
    }
    return self;
}

- (id) init {
    self = [super init];
    if (self != nil) {
        self.usernameInvalid = NO;
        self.passwordInvalid = NO;
        self.loggedIn = NO;
        self.inProgress = NO;
        self.endpointURL = [NSURL URLWithString:@"http://www.dreamwidth.org/interface/xmlrpc"];
    }
    return self;
}

-(BOOL)login {
    if (self.loggedIn || self.inProgress) return NO;
    self.inProgress = YES;
    [self asyncCallMethod:@"login" withArgs:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInt:1], @"getpickws",
                                        [NSNumber numberWithInt:1], @"getpickwurls", nil]
              andSelector:@selector(loginRequest:withArg:error:orResponse:)];
    return YES;
}

#pragma mark Internal

-(DWUser *)user {
    return self;
}

-(void)setUser:(DWUser *)user {
    return;
}

-(void)callDelegateMethodWasFailure:(BOOL)failed {
    [super callDelegateMethodWasFailure:failed];
    if (failed)
        [self.delegate loginFailed:self];
    else
        [self.delegate loginSucceeded:self];
}

-(NSDictionary *)prepareArgs:(NSDictionary *)inVal {
    NSString *challenge = [self getChallenge];
    if (challenge == nil) return nil;
    return [self prepareArgs:inVal withChallenge:challenge];
}

-(NSDictionary *)prepareArgs:(NSDictionary *)inVal withChallenge:(NSString *)challenge {

    NSMutableDictionary *dict;
    if (inVal == nil) {
        dict = [NSMutableDictionary new];
    } else {
        dict = [inVal mutableCopy];
    }
    [dict setObject:self.username forKey:@"username"];
    [dict setObject:@"challenge" forKey:@"auth_method"];
    [dict setObject:challenge forKey:@"auth_challenge"];
    [dict setObject:[[challenge stringByAppendingString:self.md5Password] md5String]
             forKey:@"auth_response"];
    return dict;
}

-(NSString *)getChallenge {
    XMLRPCRequest *req = [self getEmptyRequest];
    [req setMethod:@"LJ.XMLRPC.getchallenge"];
    
    XMLRPCResponse *response = [XMLRPCConnection sendSynchronousXMLRPCRequest:req];
    if ( !response) {
        return nil;
    } else if ([response isFault]) {
        NSLog(@"%@ %@",[response faultCode],[response faultString]);
        return nil;
    } else {
        return [[response object] objectForKey:@"challenge"];
    }
}

-(DWXMLRPCRequest *)asyncCallMethod:(NSString*)method withArgs:(NSDictionary*)args andSelector:(SEL)selector {
    return [DWXMLRPCRequest asyncRequestFor:self withMethod:method andArgs:args withObject:self andSelector:selector andArg:nil];
}

-(XMLRPCRequest *)getEmptyRequest {
    return [[[XMLRPCRequest alloc] initWithURL:endpointURL] autorelease];
}

#pragma mark Callbacks 

-(void)loginRequest:(DWXMLRPCRequest *)req withArg:(id)arg error:(NSError *)error orResponse:(XMLRPCResponse *)resp {
    self.inProgress = NO;
    if ( error || [self parseLoginResponse:resp] == NO )
        [self.delegate loginFailed:self];
}

#pragma mark Private

-(BOOL)parseLoginResponse:(XMLRPCResponse *)response {
    self.usernameInvalid = NO;
    self.passwordInvalid = NO;
    
    if ( !response ) {
        return NO;
    } else if ( [response isFault] ) {
        self.faultCode = [response faultCode];
        self.faultString = [response faultString];
        int code = [[response faultCode] intValue];
        if (code == 100) self.usernameInvalid = YES;
        if (code == 101) self.passwordInvalid = YES;
        return NO;
    } else {
        self.loggedIn = YES;
        self.faultCode = nil;
        self.faultString = nil;
        NSDictionary *obj = [response object];
        self.fullName = [obj objectForKey:@"fullname"];
        NSArray *pickws = [obj objectForKey:@"pickws"];
        NSArray *pickwurls = [obj objectForKey:@"pickwurls"];
        if (pickws && pickwurls) { // Import userpictures
            int ct = [pickws count];
            if ([pickwurls count] < ct)
                ct = [pickwurls count];
            
            NSMutableDictionary *urlMap = [NSMutableDictionary dictionary];
            NSMutableDictionary *keywords = [NSMutableDictionary dictionary];
            for (int i = 0; i < ct; i++) {
                NSString *url = [[pickwurls objectAtIndex:i] stringValue];
                NSString *kw = [[pickws objectAtIndex:i] stringValue];
                
                DWUserpic *upic = [urlMap objectForKey:url];
                if ( !upic )
                    upic = [DWUserpic userpicWithURL:[NSURL URLWithString:url]];
                [upic addKeyword:kw];
                [keywords setObject:upic forKey:kw];
                [urlMap setObject:upic forKey:url];
            }
            self.userpics = keywords;
            
            NSString *defaultPic = [[obj objectForKey:@"defaultpicurl"] stringValue];
            if (defaultPic)
                self.defaultUserpic = [urlMap objectForKey:defaultPic];
        }
        NSArray *usejournals = [obj objectForKey:@"usejournals"];
        if (usejournals) {
            NSMutableDictionary *_journals = [NSMutableDictionary dictionary];
            for (NSString *journal in usejournals) {
                [_journals setObject:[DWJournal journalWithUsername:journal andUser:self] forKey:journal];
            }
            self.journals = _journals;
        }
        [super load];
        return YES;
    }
}

@end
