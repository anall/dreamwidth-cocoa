#import <Cocoa/Cocoa.h>
#import "DWUserDelegate.h"

@class DWUser;
@interface DWJournal : NSObject {
@private    
    DWUser *user;
    NSString *username;
    NSDictionary *tags;
    
    id<DWUserDelegate> delegate;
    
    BOOL loaded;
    BOOL inProgress;
    
    int _failed;
    int _succeeded;
    
    NSDictionary *____raw_tags;
}

-(id)initWithUsername:(NSString *)name andUser:(DWUser *)user;
+(DWJournal *)journalWithUsername:(NSString *)name andUser:(DWUser *)user;

-(BOOL)load;

-(DWUser *)user;
-(NSString *)username;
-(NSDictionary *)tags;

-(void)setDelegate:(id<DWUserDelegate>)_delegate;
-(id<DWUserDelegate>)delegate;

-(BOOL)loaded;
-(BOOL)inProgress;

@end