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

+(DWUser *)userWithUsername:(NSString *)username andPassword:(NSString *)password;
+(DWUser *)userWithUsername:(NSString *)username andHashedPassword:(NSString *)password;

-(id)initWithUsername:(NSString *)username andPassword:(NSString *)password;
-(id)initWithUsername:(NSString *)username andHashedPassword:(NSString *)password;

-(BOOL)login;

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
