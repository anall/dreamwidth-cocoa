#import <Cocoa/Cocoa.h>

@interface DWUserpic : NSObject {
@private
    NSURL *url;
    NSMutableSet *keywords;
}

-(id)initWithURL:(NSURL *)url;
+(DWUserpic *)userpicWithURL:(NSURL *)url;

-(void)addKeyword:(NSString *)keyword;

-(NSURL *)url;
-(NSSet *)keywords;
@end