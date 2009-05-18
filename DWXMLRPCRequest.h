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

+(DWXMLRPCRequest *)asyncRequestFor:(DWUser *)user withMethod:(NSString *)method andArgs:(NSDictionary *)args withDelegate:(id<DWXMLRPCRequestDelegate>)what andArg:(id)arg;
+(DWXMLRPCRequest *)asyncRequestFor:(DWUser *)user withMethod:(NSString *)method andArgs:(NSDictionary *)args withObject:(id)what andSelector:(SEL)sel andArg:(id)arg;

+(BOOL)synchronous;
+(void)setSynchronous:(BOOL)value;

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