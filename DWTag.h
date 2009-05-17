#import <Cocoa/Cocoa.h>

@interface DWTag : NSObject {
    NSString *name;
    BOOL display;
    int uses;
    
    NSString *securityLevel;
}
#if (MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_4)
@property (nonatomic, retain, readonly) NSString *name;
@property (nonatomic, readonly) BOOL display;
@property (nonatomic, readonly) int uses;
@property (nonatomic, retain, readonly) NSString *securityLevel;
#endif

+(DWTag *)tagWithDictionary:(NSDictionary *)data;
-(id)initWithDictionary:(NSDictionary *)data;

@end

@interface DWTag (GenProps)

-(NSString *)name;
-(BOOL)display;
-(int)uses;
-(NSString *)securityLevel;

@end
