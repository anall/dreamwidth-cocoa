#import "NSStringAdditionsTest.h"
#import <Dreamwidth/Dreamwidth.h>

@implementation NSStringAdditionsTest

-(void)testMd5 {
    NSString *result = [@"Hello World" md5String];
    NSString *expected = @"b10a8db164e0754105b7a99be72e3fe5";
    STAssertEqualObjects(expected, result, @"MD5 result is: %@, expected: %@",result,expected);
}

@end
