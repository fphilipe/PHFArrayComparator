#import "PHFSectionsAndRowsController.h"

@interface PHFSectionsAndRowsController ()
@property (strong, nonatomic) NSArray *data;
@end

@implementation PHFSectionsAndRowsController

- (NSString *)title {
    return @"Sections & Rows";
}

- (void)refresh {
    [self setData:[self generateData]];
}

- (NSArray *)generateData {
    static NSInteger j = 0;
    ++j;
    NSUInteger sectionCount = arc4random_uniform(0) + 3;

    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:sectionCount * 2];
    for (NSUInteger i = 0; i < sectionCount; ++i)
        [newArray addObject:[NSString stringWithFormat:@"Section %d %d", arc4random_uniform(1000), j % 2]];

    NSUInteger redIndex, greenIndex, blueIndex;
    redIndex = arc4random_uniform(sectionCount);
    do
        greenIndex = arc4random_uniform(sectionCount);
    while (greenIndex == redIndex);
    do
        blueIndex = arc4random_uniform(sectionCount);
    while (blueIndex == greenIndex || blueIndex == redIndex);

    [newArray replaceObjectAtIndex:redIndex   withObject:@"Red"];
    [newArray replaceObjectAtIndex:greenIndex withObject:@"Green"];
    [newArray replaceObjectAtIndex:blueIndex  withObject:@"Blue"];

    for (NSInteger i = 1; i < sectionCount * 2; i += 2) {
        NSInteger rowCount = arc4random_uniform(3) + 1;
        NSMutableArray *rows = [NSMutableArray arrayWithCapacity:rowCount];
        [newArray insertObject:rows atIndex:i];

        NSString *string;
        for (NSInteger j = 0; j < rowCount; ++j) {
            do {
                string = [NSString stringWithFormat:@"Row %d", arc4random_uniform(5) + 1];
            } while ([rows containsObject:string]);
            [rows addObject:string];
        }
    }

    return newArray;
}

- (void)updateFromData:(NSArray *)oldData toData:(NSArray *)newData {
    [[self leftTableView] reloadData];

    UITableView *rightTableView = [self rightTableView];


    NSInteger oldDataCount = [oldData count];
    NSInteger newDataCount = [newData count];
    NSInteger j, i, newIndex;

    NSMutableArray *oldSections = [NSMutableArray arrayWithCapacity:oldDataCount];
    NSMutableArray *newSections = [NSMutableArray arrayWithCapacity:oldDataCount];

    for (i = 0; i < oldDataCount; i += 2)
        [oldSections addObject:oldData[i]];

    for (i = 0; i < newDataCount; i += 2)
        [newSections addObject:newData[i]];

    NSDictionary *instructions = [PHFArrayComparator compareOldArray:oldSections withNewArray:newSections];

    [rightTableView beginUpdates];

    for (i = 0; i < oldDataCount; i += 2) {
        newIndex = [newData indexOfObject:oldData[i]];
        if (newIndex != NSNotFound) {
            NSInteger oldSection = i / 2;
            NSInteger newSection = newIndex / 2;

            NSDictionary *instructions = [PHFArrayComparator compareOldArray:oldData[i + 1]
                                                                withNewArray:newData[newIndex + 1]];

            for (NSArray *delete in [instructions objectForKey:PHFArrayComparatorDeletesKey])
                for (j = 0; j < [delete[1] integerValue]; ++j)
                    [rightTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:([delete[0] integerValue] + j) inSection:oldSection]] withRowAnimation:UITableViewRowAnimationFade];

            for (NSArray *move in [instructions objectForKey:PHFArrayComparatorMovesKey])
                [rightTableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:[move[0] integerValue] inSection:oldSection]
                                  toIndexPath:[NSIndexPath indexPathForRow:[move[1] integerValue] inSection:newSection]];

            for (NSArray *insert in [instructions objectForKey:PHFArrayComparatorInsertsKey])
                for (j = 0; j < [insert[1] integerValue]; ++j)
                    [rightTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:([insert[0] integerValue] + j) inSection:newSection]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }

    for (NSArray *delete in [instructions objectForKey:PHFArrayComparatorDeletesKey])
        [rightTableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([delete[0] integerValue], [delete[1] integerValue])] withRowAnimation:UITableViewRowAnimationFade];

    for (NSArray *move in [instructions objectForKey:PHFArrayComparatorMovesKey])
        [rightTableView moveSection:[move[0] integerValue] toSection:[move[1] integerValue]];

    for (NSArray *insert in [instructions objectForKey:PHFArrayComparatorInsertsKey])
        [rightTableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([insert[0] integerValue], [insert[1] integerValue])] withRowAnimation:UITableViewRowAnimationFade];

    [rightTableView endUpdates];
}

@synthesize data = _data;
- (void)setData:(NSArray *)data {
    // I was not able to move sections and change rows at the same time.  It
    // would sometimes raise an exception saying that a cell has multiple
    // animations.  Therefore, we split the update into two steps:
    // 1. Update order of sections
    // 2. Update elements of sections

    if (!_data)
        _data = @[];
    
    NSInteger dataCount = [data count];
    NSMutableArray *intermediateData = [NSMutableArray arrayWithCapacity:dataCount];
    NSInteger i;
    for (i = 0; i < dataCount; i += 2) {
        id newSection = [data objectAtIndex:i];
        [intermediateData addObject:newSection];
        NSInteger oldIndex = [_data indexOfObject:newSection];
        id sectionContent;
        if (oldIndex != NSNotFound)
            sectionContent = [_data objectAtIndex:oldIndex + 1];
        else
            sectionContent = [data objectAtIndex:i + 1];
        [intermediateData addObject:sectionContent];
    }

    NSArray *oldData = _data;
    _data = intermediateData;
    [self updateFromData:oldData toData:intermediateData];

    _data = data;
    [self updateFromData:intermediateData toData:data];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self data] count] / 2;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[self data][section * 2 + 1] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self cellForTableView:tableView];
    NSString *row = [self data][[indexPath section] * 2 + 1][[indexPath row]];
    [[cell textLabel] setText:row];

    return cell;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];

    NSString *sectionItem = [self data][section * 2];
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
