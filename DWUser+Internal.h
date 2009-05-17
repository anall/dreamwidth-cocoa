#import "DWUser.h"
#import <XMLRPC/XMLRPC.h>

@class DWXMLRPCRequest;
@interface DWUser (Internal)

-(NSString *)getChallenge;
-(DWXMLRPCRequest *)asyncCallMethod:(NSString*)method withArgs:(NSDictionary*)args andSelector:(SEL)selector;

-(XMLRPCRequest *)getEmptyRequest;
-(NSDictionary *)prepareArgs:(NSDictionary *)inVal;
-(NSDictionary *)prepareArgs:(NSDictionary *)inVal withChallenge:(NSString *)challenge;
@end

