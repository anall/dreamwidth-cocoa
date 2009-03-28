#import "DWTag.h"

@interface DWTag ()
@property (nonatomic, retain, readwrite) NSString *name;
@property (nonatomic, readwrite) BOOL display;
@property (nonatomic, readwrite) int uses;
@property (nonatomic, retain, readwrite) NSString *securityLevel;
@end

@implementation DWTag
@synthesize name, display, uses;
@synthesize securityLevel;

+(DWTag *)tagWithDictionary:(NSDictionary *)data {
    return [[[DWTag alloc] initWithDictionary:data] autorelease];
}

-(id)initWithDictionary:(NSDictionary *)data {
    self = [super init];
    if (self != nil) {
        self.name = [[data objectForKey:@"name"] stringValue];
        self.display = [[data objectForKey:@"display"] boolValue];
        self.uses = [[data objectForKey:@"uses"] intValue];
        
        self.securityLevel = [[data objectForKey:@"security_level"] stringValue];
    }
    return self;
}

@end
