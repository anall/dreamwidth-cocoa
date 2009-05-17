#import "NSStringAdditions.h"
#include <openssl/md5.h>

@implementation NSString (DreamwidthAdditions)

-(NSString *)md5String {
    unsigned char digest[16];
    MD5((void *)[self cStringUsingEncoding:NSUTF8StringEncoding],[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			digest[0], digest[1], digest[2], digest[3], digest[4], digest[5],
			digest[6], digest[7],digest[8], digest[9], digest[10], digest[11],
			digest[12], digest[13], digest[14], digest[15]];
}

-(NSString *)stringValue {
    return self;
}

@end
