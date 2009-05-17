#import <Cocoa/Cocoa.h>
#import <XMLRPC/XMLRPC.h>
#import "DWXMLRPCRequestDelegate.h"

@class DWUser;
@interface DWXMLRPCRequest : NSObject<XMLRPCConnectionDelegate> {
    DWUser *user;
    NSString *method;
    NSDictionary *args;
    
    id<DWXMLRPCRequestDelegate> delegate;
    id object;
    
    SEL selector;
    id cbArg;
    
    BOOL hasChallenge;
    XMLRPCRequest *request;
    
    BOOL complete;
    BOOL failed;
}
#if (MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_4)
@property (nonatomic, retain, readonly) DWUser *user;
@property (nonatomic, retain, readonly) NSString *method;
@property (nonatomic, retain, readonly) NSDictionary *args;

@property (nonatomic, readonly) id<DWXMLRPCRequestDelegate> delegate;
@property (nonatomic, readonly) id object;
@property (nonatomic, readonly) SEL selector;
@property (nonatomic, readonly) id cbArg;

@property (nonatomic, readonly) BOOL complete;
@property (nonatomic, readonly) BOOL failed;
#endif

+(DWXMLRPCRequest *)asyncRequestFor:(DWUser *)user withMethod:(NSString *)method andArgs:(NSDictionary *)args withDelegate:(id<DWXMLRPCRequestDelegate>)what andArg:(id)arg;
+(DWXMLRPCRequest *)asyncRequestFor:(DWUser *)user withMethod:(NSString *)method andArgs:(NSDictionary *)args withObject:(id)what andSelector:(SEL)sel andArg:(id)arg;

+(BOOL)synchronous;
+(void)setSynchronous:(BOOL)value;

@end

@interface DWXMLRPCRequest (GenProps)

-(DWUser *)user;
-(NSString *)method;
-(NSDictionary *)args;

-(id<DWXMLRPCRequestDelegate>)delegate;
-(id)object;
-(SEL)selector;
-(id)cbArg;

-(BOOL)complete;
-(BOOL)failed;

@end
