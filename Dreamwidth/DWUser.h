#import <Cocoa/Cocoa.h>
#import "DWJournal.h"

@class DWUserpic;
@interface DWUser : DWJournal {
@private
    NSString *md5Password;
    NSURL *endpointURL;
    
    BOOL loggedIn;
    
    BOOL usernameInvalid;
    BOOL passwordInvalid;
    
    NSNumber *faultCode;
    NSString *faultString;

    NSString *fullName;
    NSDictionary *userpics;
    DWUserpic *defaultUserpic;
    NSDictionary *journals;
}
@property (retain) NSString *md5Password;
@property (retain) NSURL *endpointURL;

@property (readonly) BOOL loggedIn;
@property (readonly) BOOL usernameInvalid;
@property (readonly) BOOL passwordInvalid;

@property (nonatomic, retain, readonly) NSNumber *faultCode;
@property (nonatomic, retain, readonly) NSString *faultString;

@property (nonatomic, retain, readonly) NSString *fullName;
@property (nonatomic, retain, readonly) NSDictionary *userpics;
@property (nonatomic, retain, readonly) DWUserpic *defaultUserpic;
@property (nonatomic, retain, readonly) NSDictionary *journals;

+(DWUser *)userWithUsername:(NSString *)username andPassword:(NSString *)password;
+(DWUser *)userWithUsername:(NSString *)username andHashedPassword:(NSString *)password;

-(id)initWithUsername:(NSString *)username andPassword:(NSString *)password;
-(id)initWithUsername:(NSString *)username andHashedPassword:(NSString *)password;

-(BOOL)login;
@end
