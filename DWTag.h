#import <Cocoa/Cocoa.h>

@interface DWTag : NSObject {
    NSString *name;
    BOOL display;
    int uses;
    
    NSString *securityLevel;
}

+(DWTag *)tagWithDictionary:(NSDictionary *)data;
-(id)initWithDictionary:(NSDictionary *)data;

-(NSString *)name;
-(BOOL)display;
-(int)uses;
-(NSString *)securityLevel;

@end
