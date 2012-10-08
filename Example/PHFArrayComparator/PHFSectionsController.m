#import "PHFSectionsController.h"

@interface PHFSectionsController ()
@property (strong, nonatomic) NSArray *sections;
@end

@implementation PHFSectionsController

- (NSString *)title {
    return @"Sections";
}

- (void)refresh {
    [self setSections:[self generateSections]];
}

- (NSArray *)generateSections {
    static NSInteger j = 0;
    ++j;
    NSUInteger sectionsCount = arc4random_uniform(5) + 4;

    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:sectionsCount];
    for (NSUInteger i = 0; i < sectionsCount; ++i)
        [newArray addObject:[NSString stringWithFormat:@"Random %d %d", arc4random_uniform(1000), j % 2]];

    NSUInteger redIndex, greenIndex, blueIndex;
    redIndex = arc4random_uniform(sectionsCount);
    do
        greenIndex = arc4random_uniform(sectionsCount);
        while (greenIndex == redIndex);
    do
        blueIndex = arc4random_uniform(sectionsCount);
        while (blueIndex == greenIndex || blueIndex == redIndex);

    NSLog(@"r: %d, g: %d, b: %d", redIndex, greenIndex, blueIndex);
    [newArray replaceObjectAtIndex:redIndex   withObject:@"Red"];
    [newArray replaceObjectAtIndex:greenIndex withObject:@"Green"];
    [newArray replaceObjectAtIndex:blueIndex  withObject:@"Blue"];

    return newArray;
}

- (void)updateFromSections:(NSArray *)oldSections toSections:(NSArray *)newSections {
    NSDictionary *instructions = [PHFArrayComparator compareOldArray:oldSections withNewArray:newSections];

    [[self leftTableView] reloadData];

    UITableView *rightTableView = [self rightTableView];

    [rightTableView beginUpdates];

    for (NSArray *delete in [instructions objectForKey:PHFArrayComparatorDeletesKey])
        [rightTableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([delete[0] integerValue], [delete[1] integerValue])] withRowAnimation:UITableViewRowAnimationFade];

    for (NSArray *move in [instructions objectForKey:PHFArrayComparatorMovesKey])
        [rightTableView moveSection:[move[0] integerValue] toSection:[move[1] integerValue]];

    for (NSArray *insert in [instructions objectForKey:PHFArrayComparatorInsertsKey])
        [rightTableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([insert[0] integerValue], [insert[1] integerValue])] withRowAnimation:UITableViewRowAnimationFade];

    [rightTableView endUpdates];
}

@synthesize sections = _sections;
- (void)setSections:(NSArray *)sections {
    NSArray *oldSections = _sections;
    _sections = sections;
    [self updateFromSections:oldSections toSections:sections];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self cellForTableView:tableView];
    [[cell textLabel] setText:[NSString stringWithFormat:@"Row %d", [indexPath row]]];

    return cell;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];

    NSString *sectionItem = [[self sections] objectAtIndex:section];
    [label setText:sectionItem];
    if (sectionItem == @"Red")
        [label setBackgroundColor:[UIColor redColor]];
    else if (sectionItem == @"Green")
        [label setBackgroundColor:[UIColor greenColor]];
    else if (sectionItem == @"Blue")
        [label setBackgroundColor:[UIColor blueColor]];
    else
        [label setBackgroundColor:[UIColor grayColor]];

    return label;
}

@end
