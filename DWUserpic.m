#import "DWUserpic.h"

@interface DWUserpic ()
#if (MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_4)
@property (nonatomic, retain, readwrite) NSURL *url;
@property (nonatomic, retain, readwrite) NSSet *keywords;
#endif
@end

@interface DWUserpic (GenPropsI)
-(void)setUrl:(NSURL *)val;
-(void)setKeywords:(NSSet *)val;
@end

@implementation DWUserpic
#if (MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_4)
@dynamic url, keywords;
#endif

-(void)dealloc {
    [url release];
    [keywords release];
    
    [super dealloc];
}

- (id) initWithURL:(NSURL *)_url {
    self = [super init];
    if (self != nil) {
        self.url = _url;
        self.keywords = [NSMutableSet set];
    }
    return self;
}

+(DWUserpic *)userpicWithURL:(NSURL *)url {
    return [[[DWUserpic alloc] initWithURL:url] autorelease];
}

-(void)addKeyword:(NSString *)keyword {
    [(NSMutableSet *)self.keywords addObject:keyword];
}

@end
