#import <Cocoa/Cocoa.h>

@class DWUser, DWJournal;
@protocol DWUserDelegate

-(void)loginFailed:(DWUser *)user;
-(void)loginSucceeded:(DWUser *)user;
-(void)journalLoaded:(DWJournal *)journal;
-(void)journalLoadFailed:(DWJournal *)journal;

@end