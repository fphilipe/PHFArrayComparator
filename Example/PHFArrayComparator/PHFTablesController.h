#import <UIKit/UIKit.h>
#include <stdlib.h>
#import "PHFArrayComparator.h"

@interface PHFTablesController : UIViewController <
    UITableViewDataSource,
    UITableViewDelegate>

@property (nonatomic, readonly) UITableView *leftTableView;
@property (nonatomic, readonly) UITableView *rightTableView;

- (void)refresh;

- (UITableViewCell *)cellForTableView:(UITableView *)tableView;

@end
