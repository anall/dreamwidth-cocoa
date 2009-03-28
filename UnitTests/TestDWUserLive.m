#import "TestDWUserLive.h"
#import <Dreamwidth/Dreamwidth.h>
#import "DWUser+Internal.h"

// FIXME: Refactor tests to not need this.
@interface DWUser ()
@property (nonatomic, retain, readwrite) NSString *username;
@end

@interface TestDWUserLive ()
-(void)doneTesting;
-(void)skipTesting;
@end
@implementation TestDWUserLive

-(void)setUp {
    char *username = getenv("DW_TEST_USERNAME");
    char *password = getenv("DW_TEST_PASSWORD");
    char *endpoint = getenv("DW_TEST_ENDPOINT");
    [self raiseAfterFailure];
    
    if ( !username || !password ) {
        NSLog(@"Skipping: Missing environment variables");
        return;
    }
    if ( !endpoint )
        endpoint = "http://www.dreamwidth.org/interface/xmlrpc";
    
    user = [DWUser userWithUsername:[NSString stringWithCString:username] andPassword:[NSString stringWithCString:password]];
    user.endpointURL = [NSURL URLWithString:[NSString stringWithCString:endpoint]];
    user.delegate = self;
    
    callWhenUserDone = @selector(invalidSelector:andFailure:);
    callWhenJournalDone = @selector(invalidSelector:andFailure:);

    loopRunning = YES;
    [self performSelector:@selector(didTimeout:) withObject:nil afterDelay:5.0];
}

-(void)tearDown {
    while (loopRunning) {
        [[NSRunLoop currentRunLoop] runUntilDate:
         [NSDate dateWithTimeIntervalSinceNow:0.5]];
    }
}
-(void)invalidSelector:(id)blah andFailure:(BOOL)failure {
    STFail(@"Selector called when not expected.");
    [self doneTesting];
}

-(void)testLoginBadUsername {
    if (!user) return [self skipTesting];
    if (getenv("DW_TEST_SKIP_BAD")) return [self skipTesting];
    user.username = @"__xx__underscore__xx__";
    callWhenUserDone = @selector(doneLoginBadUsername:andFailure:);
    [user login];
}
-(void)doneLoginBadUsername:(DWUser *)_user andFailure:(BOOL)failure {
    STAssertEquals(YES,failure,@"Invalid login did not fail");
    STAssertEquals(YES,_user.usernameInvalid,@"Username Valid");
    [self doneTesting];
}

-(void)testLoginBadPassword {
    if (!user) return [self skipTesting];
    if (getenv("DW_TEST_SKIP_BAD")) return [self skipTesting];
    user.md5Password = @"kitten";
    callWhenUserDone = @selector(doneLoginBadPassword:andFailure:);
    [user login];
}
-(void)doneLoginBadPassword:(DWUser *)_user andFailure:(BOOL)failure {
    STAssertEquals(YES,failure,@"Invalid login did not fail");
    STAssertEquals(NO,_user.usernameInvalid,@"Username Invalid");
    STAssertEquals(YES,_user.passwordInvalid,@"Password Valid");
    [self doneTesting];
    [self performSelectorOnMainThread:@selector(stopRunLoop:) withObject:nil waitUntilDone:NO];
}

-(void)testLogin {
    if (!user) return [self skipTesting];
    
    callWhenUserDone = @selector(doneLoginUser:andFailure:);
    callWhenJournalDone = @selector(doneLoginJournal:andFailure:);
    [user login];
}
-(void)doneLoginUser:(DWUser *)_user andFailure:(BOOL)failure {
    STAssertEquals(NO,failure,@"Valid login failed");
    NSLog(@"%@ %@ %@ %@",_user.userpics,_user.defaultUserpic,_user.fullName,_user.journals);
    NSLog(@"%@ %@",_user.username,_user.tags);
    [self doneTesting];
}
-(void)doneLoginJournal:(DWJournal *)journal andFailure:(BOOL)failure {
    STAssertEquals(NO,failure,@"Journal Failed");
}

-(void)loginFailed:(DWUser *)_user {
    IMP i = [self methodForSelector:callWhenUserDone];
    i(self, callWhenUserDone, _user, YES);
}
-(void)loginSucceeded:(DWUser *)_user {
    IMP i = [self methodForSelector:callWhenUserDone];
    i(self, callWhenUserDone, _user, NO);
}

-(void)journalLoadFailed:(DWJournal *)journal {
    IMP i = [self methodForSelector:callWhenJournalDone];
    i(self, callWhenJournalDone, journal, YES);
}
-(void)journalLoaded:(DWJournal *)journal {
    IMP i = [self methodForSelector:callWhenJournalDone];
    i(self, callWhenJournalDone, journal, NO);
}

-(void)doneTesting {
    if (!loopRunning) return;
    [self performSelectorOnMainThread:@selector(stopRunLoop:) withObject:nil waitUntilDone:NO];
}
-(void)skipTesting {
    NSLog(@"Test Skipped!");
    if (!loopRunning) return;
    [self performSelectorOnMainThread:@selector(stopRunLoop:) withObject:nil waitUntilDone:NO];
}

-(void)stopRunLoop:(id)object {
    loopRunning = NO;
}
-(void)didTimeout:(id)object {
    STFail(@"Timeout waiting for response");
    [self performSelectorOnMainThread:@selector(stopRunLoop:) withObject:nil waitUntilDone:NO];
}

@end
