#import "DWJournal.h"
#import "DWJournal+Internal.h"
#import "DWUser.h"
#import "DWUser+Internal.h"
#import "DWUserDelegate.h"
#import "DWXMLRPCRequest.h"
#import "DWTag.h"
#import <XMLRPC/XMLRPC.h>
#import "InternalDefines.h"

#define NUM_TASKS 1

@implementation DWJournal

- (void) dealloc
{
    [user release];
    [username release];
    [tags release];
    
    [super dealloc];
}


#pragma mark Public

- (id) init {
    self = [super init];
    if (self != nil) {
    }
    return self;
}

-(id)initWithUsername:(NSString *)_name andUser:(DWUser *)_user {
    self = [self init];
    if (self != nil) {
        username = [_name retain];
        user = [_user retain];
    }
    return self;
}

+(DWJournal *)journalWithUsername:(NSString *)name andUser:(DWUser *)user {
    return [[[DWJournal alloc] initWithUsername:name andUser:user] autorelease];
}

-(BOOL)load {
    if (self.loaded || self.inProgress) return NO;
    
    _failed = 0;
    _succeeded = 0;
    
    self.inProgress = YES;
    
    [self.user asyncCallMethod:@"getusertags" withArgs:[NSDictionary dictionaryWithObject:self.username forKey:@"usejournal"] andSelector:@selector(tagsRequest:withArg:error:orResponse:)];
    
    return YES;
}

#pragma mark Callbacks

-(void)tagsRequest:(DWXMLRPCRequest *)req withArg:(id)arg error:(NSError *)error orResponse:(XMLRPCResponse *)resp {
    if ( error || [self parseTagResponse:resp] == NO )
        _failed++;
    else
        _succeeded++;
    [self maybeDone];
}

#pragma mark Internal

-(void)callDelegateMethodWasFailure:(BOOL)failed {
    if (failed)
        [self.delegate journalLoadFailed:self];
    else
        [self.delegate journalLoaded:self];
}

#pragma mark Private

-(BOOL)parseTagResponse:(XMLRPCResponse *)resp {
    NSMutableDictionary *_tags = [NSMutableDictionary dictionary];
    NSDictionary *tag_data = [[resp object] objectForKey:@"tags"];
    ____raw_tags = [[resp object] retain];
    if ( tag_data == nil ) return NO;
    {
        NSEnumerator *enumerator = [tag_data objectEnumerator];
        NSDictionary *data;
        while ((data = [enumerator nextObject])) {
            DWTag *tag = [DWTag tagWithDictionary:data];
            [_tags setObject:tag forKey:tag.name];
        }
    }
    tags = [_tags copy];
    return YES;
}

-(BOOL)maybeDone {
    if (_failed+_succeeded < NUM_TASKS) return NO;
    self.inProgress = NO;
    [self callDelegateMethodWasFailure:(_failed != 0)];
    if ( _failed == 0 ) {
        self.loaded = YES;
    }
    return YES;
}

#pragma mark Getters/Setters

-(DWUser *)user { return user; }

-(NSString *)username { return username; }

-(NSDictionary *)tags { return tags; }

-(id<DWUserDelegate>)delegate { return delegate; }
-(void)setDelegate:(id<DWUserDelegate>)val { SETTER_ASSIGN(delegate); }

-(BOOL)loaded { return loaded; }
-(void)setLoaded:(BOOL)val { SETTER_ASSIGN(loaded); }

-(BOOL)inProgress { return inProgress; }
-(void)setInProgress:(BOOL)val { SETTER_ASSIGN(inProgress); }

@end
