#import "DWTag.h"

@implementation DWTag

- (void) dealloc
{
    [name release];
    [securityLevel release];
    [super dealloc];
}

+(DWTag *)tagWithDictionary:(NSDictionary *)data {
    return [[[DWTag alloc] initWithDictionary:data] autorelease];
}

-(id)initWithDictionary:(NSDictionary *)data {
    self = [super init];
    if (self != nil) {
        name = [[[data objectForKey:@"name"] stringValue] retain];
        
        display = [[data objectForKey:@"display"] boolValue];
        uses = [[data objectForKey:@"uses"] intValue];
        
        securityLevel = [[[data objectForKey:@"security_level"] stringValue] retain];
    }
    return self;
}

#pragma mark Getters/Setters

-(NSString *)name { return name; }
-(BOOL)display { return display; }
-(int)uses { return uses; }
-(NSString *)securityLevel { return securityLevel; }

@end
