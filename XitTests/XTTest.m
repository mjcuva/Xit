//
//  XTTest.m
//  XTTest
//
//  Created by glaullon on 7/15/11.
//

#import "XTTest.h"
#import "XTRepository.h"
#import "XTRepository+Commands.h"

@implementation XTTest

- (void)setUp {
    [super setUp];

    repoPath = [NSString stringWithFormat:@"%@testrepo", NSTemporaryDirectory()];
    repository = [self createRepo:repoPath];

    remoteRepoPath = [NSString stringWithFormat:@"%@remotetestrepo", NSTemporaryDirectory()];
    remoteRepository = [self createRepo:remoteRepoPath];

    [self addInitialRepoContent];

    NSLog(@"setUp ok");
}

- (void)tearDown {
    [repository waitForQueue];

    NSFileManager *defaultManager = [NSFileManager defaultManager];
    [defaultManager removeItemAtPath:repoPath error:nil];
    [defaultManager removeItemAtPath:remoteRepoPath error:nil];

    if ([defaultManager fileExistsAtPath:repoPath]) {
        STFail(@"tearDown %@ FAIL!!", repoPath);
    }

    if ([defaultManager fileExistsAtPath:remoteRepoPath]) {
        STFail(@"tearDown %@ FAIL!!", remoteRepoPath);
    }

    NSLog(@"tearDown ok");

    [super tearDown];
}

// - (void)testGitError
// {
//    NSError *error = nil;
//    [xit exectuteGitWithArgs:[NSArray arrayWithObjects:@"checkout",@"-b",@"b1",nil] error:&error];
//    [xit exectuteGitWithArgs:[NSArray arrayWithObjects:@"checkout",@"-b",@"b1",nil] error:&error];
//    STAssertTrue(error!=nil, @"no error");
//    STAssertTrue([error code]!=0, @"no error");
// }

- (void)addInitialRepoContent {
    file1Path = [repoPath stringByAppendingPathComponent:@"file1.txt"];
    [@"some text" writeToFile:file1Path atomically:YES encoding:NSASCIIStringEncoding error:nil];

    if (![[NSFileManager defaultManager] fileExistsAtPath:file1Path]) {
        STFail(@"file1.txt NOT Found!!");
    }

    if (![repository addFile:@"file1.txt"]) {
        STFail(@"add file 'file1.txt'");
    }

    if (![repository commitWithMessage:@"new file1.txt"]) {
        STFail(@"Commit with mesage 'new file1.txt'");
    }
}

- (XTRepository *)createRepo:(NSString *)repoName {
    NSLog(@"[createRepo] repoName=%@", repoName);
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:repoName]) {
        [fileManager removeItemAtPath:repoName error:nil];
    }
    [fileManager createDirectoryAtPath:repoName withIntermediateDirectories:YES attributes:nil error:nil];

    NSURL *repoURL = [NSURL URLWithString:[NSString stringWithFormat:@"file://localhost%@", repoName]];

    XTRepository *repo = [[XTRepository alloc] initWithURL:repoURL];

    if (![repo initializeRepository]) {
        STFail(@"initializeRepository '%@' FAIL!!", repoName);
    }

    if (![fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/.git", repoName]]) {
        STFail(@"%@/.git NOT Found!!", repoName);
    }

    return repo;
}

- (BOOL)writeTextToFile1:(NSString *)text {
    NSError *error;

    [text writeToFile:file1Path atomically:YES encoding:NSASCIIStringEncoding error:&error];
    return error == nil;
}

@end