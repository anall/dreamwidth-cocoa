#import "DWJournal.h"
#import "DWJournal+Internal.h"
#import "DWUser.h"
#import "DWUser+Internal.h"
#import "DWUserDelegate.h"
#import "DWXMLRPCRequest.h"
#import "DWTag.h"
#import <XMLRPC/XMLRPC.h>

#define NUM_TASKS 1

@interface DWJournal ()
@property (nonatomic, retain, readwrite) NSString *username;
@property (nonatomic, retain, readwrite) DWUser *user;
@property (nonatomic, retain, readwrite) NSDictionary *tags;

@property (readwrite) BOOL loaded;
@property (readwrite) BOOL inProgress;

-(BOOL)maybeDone;
-(BOOL)parseTagResponse:(XMLRPCResponse *)resp;

-(void)tagsRequest:(DWXMLRPCRequest *)req withArg:(id)arg error:(NSError *)error orResponse:(XMLRPCResponse *)resp;

@end

@implementation DWJournal
@synthesize delegate;
@synthesize user, username, tags;
@synthesize loaded, inProgress;

#pragma mark Public

- (id) init {
    self = [super init];
    if (self != nil) {
    }
    return self;
}

-(id)initWithUsername:(NSString *)_name andUser:(DWUser *)_user {
    self = [self init];
    if (self != nil) {
        self.username = _name;
        self.user = _user;
    }
    return self;
}

+(DWJournal *)journalWithUsername:(NSString *)name andUser:(DWUser *)user {
    return [[[DWJournal alloc] initWithUsername:name andUser:user] autorelease];
}

-(BOOL)load {
    if (self.loaded || self.inProgress) return NO;
    
    _failed = 0;
    _succeeded = 0;
    
    self.inProgress = YES;
    
    [self.user asyncCallMethod:@"getusertags" withArgs:[NSDictionary dictionaryWithObject:self.username forKey:@"usejournal"] andSelector:@selector(tagsRequest:withArg:error:orResponse:)];
    
    return YES;
}

#pragma mark Callbacks

-(void)tagsRequest:(DWXMLRPCRequest *)req withArg:(id)arg error:(NSError *)error orResponse:(XMLRPCResponse *)resp {
    if ( error || [self parseTagResponse:resp] == NO )
        _failed++;
    else
        _succeeded++;
    [self maybeDone];
}

#pragma mark Internal

-(void)callDelegateMethodWasFailure:(BOOL)failed {
    if (failed)
        [self.delegate journalLoadFailed:self];
    else
        [self.delegate journalLoaded:self];
}

#pragma mark Private

-(BOOL)parseTagResponse:(XMLRPCResponse *)resp {
    NSMutableDictionary *_tags = [NSMutableDictionary dictionary];
    NSDictionary *tag_data = [[resp object] objectForKey:@"tags"];
    if ( tag_data == nil ) return NO;
    for (NSDictionary *data in tag_data) {
        DWTag *tag = [DWTag tagWithDictionary:data];
        [_tags setObject:tag forKey:tag.name];
    }
    self.tags = _tags;
    return YES;
}

-(BOOL)maybeDone {
    if (_failed+_succeeded < NUM_TASKS) return NO;
    self.inProgress = NO;
    [self callDelegateMethodWasFailure:(_failed != 0)];
    if ( _failed == 0 ) {
        self.loaded = YES;
    }
    return YES;
}
@end
