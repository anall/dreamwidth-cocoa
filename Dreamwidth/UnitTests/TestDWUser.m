#import "TestDWUser.h"
#import <Dreamwidth/Dreamwidth.h>
#import "DWUser+Internal.h"

@implementation TestDWUser

-(void)testGetChallenge {
    DWUser *u = [DWUser userWithUsername:@"test" andPassword:@"test"];
    NSString *challenge = [u getChallenge];
    
    STAssertNotNil(challenge, @"XML-RPC call failed.");
}

-(void)testWithUsernameAndPassword {
    DWUser *u = [DWUser userWithUsername:@"test" andPassword:@"test"];
    
    STAssertNotNil(u,@"User is nil");
    STAssertEqualObjects(@"test", u.username, @"Incorrect username, expected: test, was: %@",u.username);
    STAssertEqualObjects(@"098f6bcd4621d373cade4e832627b4f6", u.md5Password, @"Incorrect password, expected: 098f6bcd4621d373cade4e832627b4f6, was: %@",u.md5Password);
    STAssertEquals(NO, u.loggedIn, @"User already logged in");
}

-(void)testWithUsernameAndHashedPassword {
    DWUser *u = [DWUser userWithUsername:@"test" andHashedPassword:@"test"];
    
    STAssertNotNil(u,@"User is nil");
    STAssertEqualObjects(@"test", u.username, @"Incorrect username, expected: test, was: %@",u.username);
    STAssertEqualObjects(@"test", u.md5Password, @"Incorrect password, expected: test, was: %@",u.md5Password);
    STAssertEquals(NO, u.loggedIn, @"User already logged in");
}

@end
