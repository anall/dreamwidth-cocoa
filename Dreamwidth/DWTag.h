#import <Cocoa/Cocoa.h>

@interface DWTag : NSObject {
    NSString *name;
    BOOL display;
    int uses;
    
    NSString *securityLevel;
}
@property (nonatomic, retain, readonly) NSString *name;
@property (nonatomic, readonly) BOOL display;
@property (nonatomic, readonly) int uses;
@property (nonatomic, retain, readonly) NSString *securityLevel;

+(DWTag *)tagWithDictionary:(NSDictionary *)data;
-(id)initWithDictionary:(NSDictionary *)data;

@end
