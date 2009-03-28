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
}
@property (nonatomic, retain, readonly) DWUser *user;
@property (nonatomic, retain, readonly) NSString *username;
@property (nonatomic, retain, readonly) NSDictionary *tags;

@property (nonatomic) id<DWUserDelegate> delegate;

@property (readonly) BOOL loaded;
@property (readonly) BOOL inProgress;

-(id)initWithUsername:(NSString *)name andUser:(DWUser *)user;
+(DWJournal *)journalWithUsername:(NSString *)name andUser:(DWUser *)user;

-(BOOL)load;
@end
