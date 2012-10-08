#import "PHFTablesController.h"

static NSString * const kCellIdentifier = @"cell";

@interface PHFTablesController ()

@end

@implementation PHFTablesController

- (id)init {
    self = [super init];

    [self refresh];

    UIBarButtonItem *refreshButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                       target:self
                                                                                       action:@selector(refresh)];
    [[self navigationItem] setRightBarButtonItems:@[refreshButtonItem]];

    return self;
}

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    [self setView:view];

    [view addSubview:[self leftTableView]];
    [view addSubview:[self rightTableView]];
}

- (void)viewWillAppear:(BOOL)animated {
}

#pragma mark - Public

- (void)refresh {}

- (UITableViewCell *)cellForTableView:(UITableView *)tableView {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:kCellIdentifier];

    return cell;
}

#pragma mark - Accessors

@synthesize leftTableView = _leftTableView;
- (UITableView *)leftTableView {
    if (!_leftTableView) {
        _leftTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 159, 100)];
        [_leftTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleRightMargin];
        [_leftTableView setDataSource:self];
        [_leftTableView setDelegate:self];
        [_leftTableView setRowHeight:25];
    }

    return _leftTableView;
}

@synthesize rightTableView = _rightTableView;
- (UITableView *)rightTableView {
    if (!_rightTableView) {
        _rightTableView = [[UITableView alloc] initWithFrame:CGRectMake(160, 0, 160, 100)];
        [_rightTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin];
        [_rightTableView setDataSource:self];
        [_rightTableView setDelegate:self];
        [_rightTableView setRowHeight:25];
    }

    return _rightTableView;
}

@end
