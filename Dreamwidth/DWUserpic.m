#import "DWUserpic.h"

@interface DWUserpic ()
@property (nonatomic, retain, readwrite) NSURL *url;
@property (nonatomic, retain, readwrite) NSSet *keywords;
@end

@implementation DWUserpic
@synthesize url, keywords;

- (id) initWithURL:(NSURL *)_url {
    self = [super init];
    if (self != nil) {
        self.url = _url;
        self.keywords = [NSSet set];
    }
    return self;
}

+(DWUserpic *)userpicWithURL:(NSURL *)url {
    return [[[DWUserpic alloc] initWithURL:url] autorelease];
}

-(void)addKeyword:(NSString *)keyword {
    self.keywords = [self.keywords setByAddingObject:keyword];
}

@end
