#import <SenTestingKit/SenTestingKit.h>
#import <Dreamwidth/Dreamwidth.h>

@interface TestDWUserLive : SenTestCase <DWUserDelegate> {
    DWUser *user;
    SEL callWhenUserDone;
    SEL callWhenJournalDone;
    BOOL loopRunning;
}

@end
