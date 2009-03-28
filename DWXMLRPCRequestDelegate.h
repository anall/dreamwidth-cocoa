#import <Cocoa/Cocoa.h>
#import <XMLRPC/XMLRPC.h>

@class DWXMLRPCRequest;
@protocol DWXMLRPCRequestDelegate

-(void)asyncRequest:(DWXMLRPCRequest *)req didReceiveResponse: (XMLRPCResponse *)response;
-(void)asyncRequest:(DWXMLRPCRequest *)req didFailWithError: (NSError *)error;

@end
