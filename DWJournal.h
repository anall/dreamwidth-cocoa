#import <Cocoa/Cocoa.h>
#import "DWUserDelegate.h"

@class DWUser;
@interface DWJournal : NSObject {
    DWUser *user;
    NSString *username;
    NSDictionary *tags;
    
    id<DWUserDelegate> delegate;
    
    BOOL loaded;
    BOOL inProgress;
    
    int _failed;
    int _succeeded;
}
#if (MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_4)
@property (nonatomic, retain, readonly) DWUser *user;
@property (nonatomic, retain, readonly) NSString *username;
@property (nonatomic, retain, readonly) NSDictionary *tags;

@property (nonatomic, assign) id<DWUserDelegate> delegate;

@property (nonatomic, readonly) BOOL loaded;
@property (nonatomic, readonly) BOOL inProgress;
#endif

-(id)initWithUsername:(NSString *)name andUser:(DWUser *)user;
+(DWJournal *)journalWithUsername:(NSString *)name andUser:(DWUser *)user;

-(BOOL)load;

@end

@interface DWJournal (GenProps)

-(DWUser *)user;
-(NSString *)username;
-(NSDictionary *)tags;

-(void)setDelegate:(id<DWUserDelegate>)_delegate;
-(id<DWUserDelegate>)delegate;

-(BOOL)loaded;
-(BOOL)inProgress;

@end