#import "DWJournal.h"
#import <XMLRPC/XMLRPC.h>

@interface DWJournal (Internal)

-(void)callDelegateMethodWasFailure:(BOOL)_failed;
@end