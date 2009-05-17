#import "DWXMLRPCRequest.h"
#import "DWUser.h"
#import "DWUser+Internal.h"

static BOOL _synchronous;

// FIXME: Test this
@interface DWXMLRPCRequest ()
#if (MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_4)
@property (nonatomic, retain, readwrite) DWUser *user;
@property (nonatomic, retain, readwrite) NSString *method;
@property (nonatomic, retain, readwrite) NSDictionary *args;

@property (nonatomic, assign, readwrite) id<DWXMLRPCRequestDelegate> delegate;
@property (nonatomic, assign, readwrite) id object;
@property (nonatomic, assign, readwrite) SEL selector;

@property (nonatomic, assign, readwrite) id cbArg;

@property (nonatomic, retain) XMLRPCRequest *request;

@property (nonatomic, readwrite) BOOL complete;
@property (nonatomic, readwrite) BOOL failed;
#endif

-(void)call;
-(void)callRequest:(XMLRPCRequest *)req;
@end

@interface DWXMLRPCRequest (GenPropsI)
-(void)setUser:(DWUser *)val;
-(void)setMethod:(NSString *)val;
-(void)setArgs:(NSDictionary *)val;

-(void)setDelegate:(id<DWXMLRPCRequestDelegate>)val;
-(void)setObject:(id)val;
-(void)setSelector:(SEL)val;

-(void)setCbArg:(id)val;

-(XMLRPCRequest *)request;
-(void)setRequest:(XMLRPCRequest *)val;

-(void)setComplete:(BOOL)val;
-(void)setFailed:(BOOL)val;

@end

@implementation DWXMLRPCRequest
#if (MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_4)
@dynamic user, method, args;
@dynamic delegate, object, selector, cbArg;
@dynamic request, complete, failed;
#endif

-(void)dealloc
{
    [user release];
    [method release];
    [args release];
    
    [request release];
    
    [super dealloc];
}

+(BOOL)synchronous {
    return _synchronous;
}

+(void)setSynchronous:(BOOL)value {
    _synchronous = value;
}

#pragma mark Public

- (id) init
{
    self = [super init];
    if (self != nil) {
        hasChallenge = NO;
        self.request = nil;
    }
    return self;
}

+(DWXMLRPCRequest *)asyncRequestFor:(DWUser *)user withMethod:(NSString *)method andArgs:(NSDictionary *)args withDelegate:(id<DWXMLRPCRequestDelegate>)what andArg:(id)arg {
    DWXMLRPCRequest *req = [DWXMLRPCRequest new];
    req.user = user;
    req.method = method;
    req.args = args;
    
    req.delegate = what;
    req.cbArg = arg;
    
    [req call];
    return req;
}

+(DWXMLRPCRequest *)asyncRequestFor:(DWUser *)user withMethod:(NSString *)method andArgs:(NSDictionary *)args withObject:(id)what andSelector:(SEL)sel andArg:(id)arg {
    DWXMLRPCRequest *req = [DWXMLRPCRequest new];
    req.user = user;
    req.method = method;
    req.args = args;
    
    req.object = what;
    req.selector = sel;
    req.cbArg = arg;
    
    [req call];
    return req;
}

# pragma mark Private

-(void)call {
    XMLRPCRequest *req = [self.user getEmptyRequest];
    [req setMethod:@"LJ.XMLRPC.getchallenge"];
    [self callRequest:req];
}

-(void)callRequest:(XMLRPCRequest *)_request {
    XMLRPCConnectionManager *manager = [XMLRPCConnectionManager sharedManager];
    self.request = _request;
    if (_synchronous) {
        XMLRPCResponse *resp = [XMLRPCConnection sendSynchronousXMLRPCRequest:_request];
        if (resp) {
            [self request:_request didReceiveResponse:resp];
        } else {
            [self request:_request didFailWithError:nil];
        }
    } else {
        [manager spawnConnectionWithXMLRPCRequest:_request delegate:self];

    }
}

#pragma mark Delegate Methods

- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)response {
    if (hasChallenge) {
        self.request = nil;
        if (self.delegate) {
            self.complete = YES;
            [self.delegate asyncRequest:self didReceiveResponse:response];
        } else if (self.object && [self.object respondsToSelector:self.selector]) {
            IMP test = [self.object methodForSelector:self.selector];
            test(self.object, self.selector, self, self.cbArg, nil, response);
        }
    } else { // Just assume this is the challenge response.
        hasChallenge = YES;
        if ( [response isFault] ) {
            if (self.delegate) {
                self.failed = YES;
                [self.delegate asyncRequest:self didReceiveResponse:response];
            } else if (self.object && [self.object respondsToSelector:self.selector]) {
                IMP test = [self.object methodForSelector:self.selector];
                test(self.object, self.selector, self, self.cbArg, nil, response);
            }
        } else {
            NSString *challenge = [[response object] objectForKey:@"challenge"];
            self.args = [self.user prepareArgs:self.args withChallenge:challenge];
            
            XMLRPCRequest *req = [self.user getEmptyRequest];
            [req setMethod:[NSString stringWithFormat:@"LJ.XMLRPC.%@",self.method] withParameter:self.args];
            [self callRequest:req];
        }
    }
}

- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error {
    self.failed = YES;
    if (self.delegate) {
        [self.delegate asyncRequest:self didFailWithError:error];
    } else if (self.object && [self.object respondsToSelector:self.selector]) {
        IMP call = [self.object methodForSelector:self.selector];
        call(self.object, self.selector, self, self.cbArg, error, nil);
    }
}

// FIXME: No idea what to do with these.
- (void)request: (XMLRPCRequest *)request didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge {}
- (void)request: (XMLRPCRequest *)request didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge {}

@end