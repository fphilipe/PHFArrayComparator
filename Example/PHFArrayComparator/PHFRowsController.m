#import "PHFRowsController.h"

@interface PHFRowsController ()
@property (strong, nonatomic) NSArray *rows;
@end

@implementation PHFRowsController

- (NSString *)title {
    return @"Rows";
}

- (void)refresh {
    [self setRows:[self generateRows]];
}

- (NSArray *)generateRows {
    static NSInteger j = 0;
    ++j;
    NSUInteger rowCount = arc4random_uniform(15) + 4;

    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:rowCount];
    for (NSUInteger i = 0; i < rowCount; ++i)
        [newArray addObject:[NSString stringWithFormat:@"Random %d %d", arc4random_uniform(1000), j % 2]];

    NSUInteger redIndex, greenIndex, blueIndex;
    redIndex = arc4random_uniform(rowCount);
    do
        greenIndex = arc4random_uniform(rowCount);
        while (greenIndex == redIndex);
    do
        blueIndex = arc4random_uniform(rowCount);
        while (blueIndex == greenIndex || blueIndex == redIndex);

    NSLog(@"r: %d, g: %d, b: %d", redIndex, greenIndex, blueIndex);
    [newArray replaceObjectAtIndex:redIndex   withObject:@"Red"];
    [newArray replaceObjectAtIndex:greenIndex withObject:@"Green"];
    [newArray replaceObjectAtIndex:blueIndex  withObject:@"Blue"];

    return newArray;
}

@synthesize rows = _rows;
- (void)setRows:(NSArray *)rows {
    NSArray *oldRows = _rows;
    _rows = rows;

    [self updateFromRows:oldRows toRows:rows];
}

- (void)updateFromRows:(NSArray *)oldRows toRows:(NSArray *)newRows {
    NSDictionary *instructions = [PHFArrayComparator compareOldArray:oldRows withNewArray:newRows];

    [[self leftTableView] reloadData];

    NSInteger i;

    UITableView *rightTableView = [self rightTableView];

    [rightTableView beginUpdates];

    for (NSArray *delete in [instructions objectForKey:PHFArrayComparatorDeletesKey])
        for (i = 0; i < [delete[1] integerValue]; ++i)
            [rightTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:([delete[0] integerValue] + i) inSection:0]] withRowAnimation:UITableViewRowAnimationFade];

    for (NSArray *move in [instructions objectForKey:PHFArrayComparatorMovesKey])
        [rightTableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:[move[0] integerValue] inSection:0]
                          toIndexPath:[NSIndexPath indexPathForRow:[move[1] integerValue] inSection:0]];

    for (NSArray *insert in [instructions objectForKey:PHFArrayComparatorInsertsKey])
        for (i = 0; i < [insert[1] integerValue]; ++i)
            [rightTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:([insert[0] integerValue] + i) inSection:0]] withRowAnimation:UITableViewRowAnimationFade];

    [rightTableView endUpdates];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[self rows] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self cellForTableView:tableView];

    NSString *rowItem = [[self rows] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:rowItem];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *rowItem = [[self rows] objectAtIndex:[indexPath row]];
    if (rowItem == @"Red")
        [cell setBackgroundColor:[UIColor redColor]];
    else if (rowItem == @"Green")
        [cell setBackgroundColor:[UIColor greenColor]];
    else if (rowItem == @"Blue")
        [cell setBackgroundColor:[UIColor blueColor]];
    else
        [cell setBackgroundColor:[UIColor whiteColor]];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == [self leftTableView])
        return @"Not Fluid";
    else
        return @"Fluid";
}

@end
