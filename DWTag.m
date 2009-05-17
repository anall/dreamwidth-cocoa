#import "DWTag.h"

@interface DWTag ()
#if (MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_4)
@property (nonatomic, retain, readwrite) NSString *name;
@property (nonatomic, readwrite) BOOL display;
@property (nonatomic, readwrite) int uses;
@property (nonatomic, retain, readwrite) NSString *securityLevel;
#endif

@end

@interface DWTag (GenPropsI)

-(void)setName:(NSString *)val;
-(void)setDisplay:(BOOL)val;
-(void)setUses:(int)val;
-(void)setSecurityLevel:(NSString *)val;

@end

@implementation DWTag
#if (MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_4)
@dynamic name;
@dynamic display,uses;
@dynamic securityLevel;
#endif

- (void) dealloc
{
    [name release];
    [securityLevel release];
    [super dealloc];
}


-(void)setName:(NSString *)_value {
    [self willChangeValueForKey:@"name"];
    [_value retain];
    [name release];
    name = _value;
    [self didChangeValueForKey:@"name"];
}

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
