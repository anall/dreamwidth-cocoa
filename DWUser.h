#import <Cocoa/Cocoa.h>
#import "DWJournal.h"

@class DWUserpic;
@interface DWUser : DWJournal {
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
#if (MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_4)
@property (nonatomic, retain) NSString *md5Password;
@property (nonatomic, retain) NSURL *endpointURL;

@property (nonatomic, readonly) BOOL loggedIn;
@property (nonatomic, readonly) BOOL usernameInvalid;
@property (nonatomic, readonly) BOOL passwordInvalid;

@property (nonatomic, retain, readonly) NSNumber *faultCode;
@property (nonatomic, retain, readonly) NSString *faultString;

@property (nonatomic, retain, readonly) NSString *fullName;
@property (nonatomic, retain, readonly) NSDictionary *userpics;
@property (nonatomic, retain, readonly) DWUserpic *defaultUserpic;
@property (nonatomic, retain, readonly) NSDictionary *journals;
#endif

+(DWUser *)userWithUsername:(NSString *)username andPassword:(NSString *)password;
+(DWUser *)userWithUsername:(NSString *)username andHashedPassword:(NSString *)password;

-(id)initWithUsername:(NSString *)username andPassword:(NSString *)password;
-(id)initWithUsername:(NSString *)username andHashedPassword:(NSString *)password;

-(BOOL)login;
@end

@interface DWUser (GenProps)
-(NSString *)md5Password;
-(void)setMd5Password:(NSString *)val;

-(NSURL *)endpointURL;
-(void)setEndpointURL:(NSURL *)val;

-(BOOL)loggedIn;
-(BOOL)usernameInvalid;
-(BOOL)passwordInvalid;

-(NSNumber *)faultCode;
-(NSString *)faultString;

-(NSString *)fullName;
-(NSDictionary *)userpics;
-(DWUserpic *)defaultUserpic;
-(NSDictionary *)journals;
@end
