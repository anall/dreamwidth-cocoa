#import "DWUserpic.h"
#import "InternalDefines.h"

@implementation DWUserpic

-(void)dealloc {
    [url release];
    [keywords release];
    
    [super dealloc];
}

- (id) initWithURL:(NSURL *)_url {
    self = [super init];
    if (self != nil) {
        url = [_url retain];
        keywords = [[NSMutableSet alloc] init];
    }
    return self;
}

+(DWUserpic *)userpicWithURL:(NSURL *)url {
    return [[[DWUserpic alloc] initWithURL:url] autorelease];
}

-(void)addKeyword:(NSString *)keyword {
    [keywords addObject:keyword];
}

#pragma mark Getters/Setters

-(NSURL *)url { return url; }
-(NSSet *)keywords { return [[keywords copy] autorelease]; }

@end
