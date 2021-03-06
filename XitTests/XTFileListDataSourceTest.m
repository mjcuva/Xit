#import "XTTest.h"
#import "XTHistoryDataSource.h"
#import "XTRepository+Commands.h"
#import "XTFileListDataSource.h"
#import "XTHistoryItem.h"

@interface XTFileListDataSourceTest : XTTest

@end

@implementation XTFileListDataSourceTest

- (void)testHistoricFileList {
    NSString *txt = @"some text";

    for (int n = 0; n < 10; n++) {
        NSString *file = [NSString stringWithFormat:@"%@/file_%u.txt", repoPath, n];
        [txt writeToFile:file atomically:YES encoding:NSASCIIStringEncoding error:nil];
        [repository addFile:@"--all"];
        [repository commitWithMessage:@"commit"];
    }

    XTHistoryDataSource *hds = [[XTHistoryDataSource alloc] init];
    [hds setRepo:repository];
    [self waitForRepoQueue];

    int expectedNF = 11;
    for (XTHistoryItem *item in hds.items) {
        repository.selectedCommit = item.sha;

        XTFileListDataSource *flds = [[XTFileListDataSource alloc] init];
        [flds setRepo:repository];
        [self waitForRepoQueue];

        NSInteger nf = [flds outlineView:nil numberOfChildrenOfItem:nil];
        STAssertTrue((nf == expectedNF), @"found %d files, expected %d files", nf, expectedNF);
        expectedNF--;
    }
}

- (void)testMultipleFileList {
    NSString *txt = @"some text";

    [[NSFileManager defaultManager] createDirectoryAtPath:[repoPath stringByAppendingPathComponent:@"dir_0/subdir_0"] withIntermediateDirectories:YES attributes:nil error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:[repoPath stringByAppendingPathComponent:@"dir_0/subdir_1"] withIntermediateDirectories:YES attributes:nil error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:[repoPath stringByAppendingPathComponent:@"dir_0/subdir_2"] withIntermediateDirectories:YES attributes:nil error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:[repoPath stringByAppendingPathComponent:@"dir_1/subdir_0"] withIntermediateDirectories:YES attributes:nil error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:[repoPath stringByAppendingPathComponent:@"dir_1/subdir_1"] withIntermediateDirectories:YES attributes:nil error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:[repoPath stringByAppendingPathComponent:@"dir_1/subdir_2"] withIntermediateDirectories:YES attributes:nil error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:file1Path error:nil];

    for (int n = 0; n < 12; n++) {
        NSString *file = [NSString stringWithFormat:@"%@/dir_%d/subdir_%d/file_%d.txt", repoPath, n % 2, n % 3, n];
        [txt writeToFile:file atomically:YES encoding:NSASCIIStringEncoding error:nil];
    }
    [repository addFile:@"--all"];
    [repository commitWithMessage:@"commit"];

    XTHistoryDataSource *hds = [[XTHistoryDataSource alloc] init];
    [hds setRepo:repository];
    [self waitForRepoQueue];

    XTHistoryItem *item = (XTHistoryItem *)(hds.items)[0];
    repository.selectedCommit = item.sha;

    XTFileListDataSource *flds = [[XTFileListDataSource alloc] init];
    [flds setRepo:repository];
    [self waitForRepoQueue];

    NSInteger nf = [flds outlineView:nil numberOfChildrenOfItem:nil];
    STAssertTrue((nf == 2), @"found %d files", nf);

    for (int rootIdx = 0; rootIdx < nf; rootIdx++) {
        NSTreeNode *root = [flds outlineView:nil child:rootIdx ofItem:nil];
        NSInteger rnf = [flds outlineView:nil numberOfChildrenOfItem:root];
        STAssertTrue((rnf == 3), @"found %d files", nf);
    }
}

@end
