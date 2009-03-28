#import <Cocoa/Cocoa.h>

@interface DWUserpic : NSObject {
@private
    NSURL *url;
    NSSet *keywords;
}
@property (nonatomic, retain, readonly) NSURL *url;
@property (nonatomic, retain, readonly) NSSet *keywords;

-(id)initWithURL:(NSURL *)url;
+(DWUserpic *)userpicWithURL:(NSURL *)url;

-(void)addKeyword:(NSString *)keyword;

@end
