#import <Foundation/Foundation.h>

@interface XTFileIndexInfo : NSObject
{
    @private
    NSString *name;
    NSString *status;
}

@property (strong) NSString *name;
@property (strong) NSString *status;

- (id)initWithName:(NSString *)theName andStatus:(NSString *)theStatus;

@end
