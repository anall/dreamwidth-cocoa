#import "DWXMLRPCRequest.h"
#import "DWUser.h"
#import "DWUser+Internal.h"
#import "InternalDefines.h"

static BOOL _synchronous;

// FIXME: Test this
@interface DWXMLRPCRequest ()
-(void)call;
-(void)callRequest:(XMLRPCRequest *)req;

-(XMLRPCRequest *)request;
-(void)setRequest:(XMLRPCRequest *)val;

-(void)setArgs:(NSDictionary *)val;

-(void)setComplete:(BOOL)val;
-(void)setFailed:(BOOL)val;

-(id)initAsyncRequest:(DWUser *)_user withMethod:(NSString *)_method andArgs:(NSDictionary *)_args withDelegate:(id<DWXMLRPCRequestDelegate>)_what andArg:(id)_arg;
-(id)initAsyncRequest:(DWUser *)_user withMethod:(NSString *)_method andArgs:(NSDictionary *)_args withObject:(id)_what andSelector:(SEL)_sel andArg:(id)_arg;

@end

@implementation DWXMLRPCRequest

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

- (id) init {
    self = [super init];
    if (self != nil) {
        hasChallenge = NO;
        self.request = nil;
    }
    return self;
}

- (id) initAsyncRequest:(DWUser *)_user withMethod:(NSString *)_method andArgs:(NSDictionary *)_args withDelegate:(id<DWXMLRPCRequestDelegate>)_what andArg:(id)_arg {
    self = [self init];
    if (self != nil) {
        user = [_user retain];
        method = [_method copy];
        args = [_args copy];
        delegate = _what;
        cbArg = _arg;
    }
    return self;
}
- (id) initAsyncRequest:(DWUser *)_user withMethod:(NSString *)_method andArgs:(NSDictionary *)_args withObject:(id)_what andSelector:(SEL)_sel andArg:(id)_arg {
    self = [self init];
    if (self != nil) {
        user = [_user retain];
        method = [_method copy];
        args = [_args copy];
        object = _what;
        selector = _sel;
        cbArg = _arg;
    }
    return self;
}

 
+(DWXMLRPCRequest *)asyncRequestFor:(DWUser *)user withMethod:(NSString *)method andArgs:(NSDictionary *)args withDelegate:(id<DWXMLRPCRequestDelegate>)what andArg:(id)arg {
    DWXMLRPCRequest *req = [[DWXMLRPCRequest alloc] initAsyncRequest:user withMethod:method andArgs:args withDelegate:what andArg:arg];
    [req call];
    return req;
}

+(DWXMLRPCRequest *)asyncRequestFor:(DWUser *)user withMethod:(NSString *)method andArgs:(NSDictionary *)args withObject:(id)what andSelector:(SEL)sel andArg:(id)arg {
    DWXMLRPCRequest *req = [[DWXMLRPCRequest alloc] initAsyncRequest:user withMethod:method andArgs:args withObject:what andSelector:sel andArg:arg];
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
            [self autorelease]; // We retain ourselves, and now we're done with ourselves.
        } else if (self.object && [self.object respondsToSelector:self.selector]) {
            IMP test = [self.object methodForSelector:self.selector];
            test(self.object, self.selector, self, self.cbArg, nil, response);
            [self autorelease]; // We retain ourselves, and now we're done with ourselves.
        }
    } else { // Just assume this is the challenge response.
        hasChallenge = YES;
        if ( [response isFault] ) {
            if (self.delegate) {
                self.failed = YES;
                [self.delegate asyncRequest:self didReceiveResponse:response];
                [self autorelease]; // We retain ourselves, and now we're done with ourselves.
            } else if (self.object && [self.object respondsToSelector:self.selector]) {
                IMP test = [self.object methodForSelector:self.selector];
                test(self.object, self.selector, self, self.cbArg, nil, response);
                [self autorelease]; // We retain ourselves, and now we're done with ourselves.
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

#pragma mark Gettters/Setters

-(DWUser *)user { return user; }
-(NSString *)method { return method; }

-(NSDictionary *)args { return args; }
-(void)setArgs:(NSDictionary *)val { SETTER_COPY(args); }

-(id<DWXMLRPCRequestDelegate>)delegate { return delegate; }
-(void)setDelegate:(id<DWXMLRPCRequestDelegate>)val { SETTER_ASSIGN(delegate); }

-(id)object { return object; }
-(SEL)selector { return selector; }
-(id)cbArg { return cbArg; }

-(BOOL)complete { return complete; }
-(void)setComplete:(BOOL)val { SETTER_ASSIGN(complete); }

-(BOOL)failed { return failed; }
-(void)setFailed:(BOOL)val { SETTER_ASSIGN(failed); }

-(XMLRPCRequest *)request { return request; }
-(void)setRequest:(XMLRPCRequest *)val { SETTER_RETAIN(request); }

@end