#import "DWJournal.h"
#import <XMLRPC/XMLRPC.h>

@class DWXMLRPCRequest;
@interface DWJournal ()

-(BOOL)maybeDone;
-(BOOL)parseTagResponse:(XMLRPCResponse *)resp;

-(void)tagsRequest:(DWXMLRPCRequest *)req withArg:(id)arg error:(NSError *)error orResponse:(XMLRPCResponse *)resp;

-(void)setLoaded:(BOOL)_loaded;
-(void)setInProgress:(BOOL)_inProgress;
@end

@interface DWJournal (Internal)

-(void)callDelegateMethodWasFailure:(BOOL)_failed;

@end