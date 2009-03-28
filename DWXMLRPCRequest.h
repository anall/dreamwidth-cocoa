#import <Cocoa/Cocoa.h>
#import <XMLRPC/XMLRPC.h>
#import "DWXMLRPCRequestDelegate.h"

@class DWUser;
@interface DWXMLRPCRequest : NSObject<XMLRPCConnectionDelegate> {
@private
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
@property (nonatomic, retain, readonly) DWUser *user;
@property (nonatomic, retain, readonly) NSString *method;
@property (nonatomic, retain, readonly) NSDictionary *args;

@property (readonly) id<DWXMLRPCRequestDelegate> delegate;
@property (readonly) id object;
@property (readonly) SEL selector;
@property (nonatomic, readonly) id cbArg;

@property (readonly) BOOL complete;
@property (readonly) BOOL failed;

+(DWXMLRPCRequest *)asyncRequestFor:(DWUser *)user withMethod:(NSString *)method andArgs:(NSDictionary *)args withDelegate:(id<DWXMLRPCRequestDelegate>)what andArg:(id)arg;
+(DWXMLRPCRequest *)asyncRequestFor:(DWUser *)user withMethod:(NSString *)method andArgs:(NSDictionary *)args withObject:(id)what andSelector:(SEL)sel andArg:(id)arg;

+(BOOL)synchronous;
+(void)setSynchronous:(BOOL)value;

@end
