#import <Cocoa/Cocoa.h>

@interface DWUserpic : NSObject {
    NSURL *url;
    NSSet *keywords;
}
#if (MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_4)
@property (nonatomic, retain, readonly) NSURL *url;
@property (nonatomic, retain, readonly) NSSet *keywords;
#endif

-(id)initWithURL:(NSURL *)url;
+(DWUserpic *)userpicWithURL:(NSURL *)url;

-(void)addKeyword:(NSString *)keyword;

@end

@interface DWUserpic (GenProps)
-(NSURL *)url;
-(NSSet *)keywords;
@end