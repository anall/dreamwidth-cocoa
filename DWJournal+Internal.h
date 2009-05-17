#import "DWJournal.h"
#import <XMLRPC/XMLRPC.h>

@class DWXMLRPCRequest;
@interface DWJournal ()
#if (MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_4)
@property (nonatomic, retain, readwrite) NSString *username;
@property (nonatomic, retain, readwrite) DWUser *user;
@property (nonatomic, retain, readwrite) NSDictionary *tags;

@property (nonatomic, readwrite) BOOL loaded;
@property (nonatomic, readwrite) BOOL inProgress;
#endif


-(BOOL)maybeDone;
-(BOOL)parseTagResponse:(XMLRPCResponse *)resp;

-(void)tagsRequest:(DWXMLRPCRequest *)req withArg:(id)arg error:(NSError *)error orResponse:(XMLRPCResponse *)resp;
@end

@interface DWJournal (GenPropsI)

-(void)setUser:(DWUser *)_user;
-(void)setUsername:(NSString *)_username;
-(void)setTags:(NSDictionary *)_tags;

-(void)setLoaded:(BOOL)_loaded;
-(void)setInProgress:(BOOL)_inProgress;

@end

@interface DWJournal (Internal)

-(void)callDelegateMethodWasFailure:(BOOL)_failed;
@end