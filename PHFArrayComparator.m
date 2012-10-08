#import "PHFArrayComparator.h"

NSString * const PHFArrayComparatorDeletesKey = @"PHFArrayComparatorDeletesKey";
NSString * const PHFArrayComparatorMovesKey   = @"PHFArrayComparatorMovesKey";
NSString * const PHFArrayComparatorInsertsKey = @"PHFArrayComparatorInsertsKey";

@implementation PHFArrayComparator {
    NSArray *oldArray;
    NSArray *newArray;
}

+ (NSDictionary *)compareOldArray:(NSArray *)oldArray
                     withNewArray:(NSArray *)newArray
{
    return [[[self alloc] initWithOldArray:oldArray newArray:newArray] compare];
}

- (id)init {
    [NSException raise:NSStringFromClass([self class]) format:@"Please use designated initializer!"];
    return nil;
}

- (id)initWithOldArray:(NSArray *)oldArray_
              newArray:(NSArray *)newArray_
{
    self = [super init];

    if (self) {
        oldArray = oldArray_ ? oldArray_ : @[];
        newArray = newArray_ ? newArray_ : @[];
    }

    return self;
}

// The basic algorithm is as follows:
// - see which items still exist (persisted items)
// - find the new order of the persisted items
// - list the indexes of items in the old array to be deleted
// - list the moves needed to perform to respect the order of persisted items
// - list the indexes of items in the new array to be inserted
- (NSDictionary *)compare {
    NSInteger i, j, from, to, count;

    NSInteger oldCount = [oldArray count];
    NSInteger newCount = [newArray count];

    // The array capacity is just an educated guess.
    NSMutableArray *oldIndexes = [NSMutableArray arrayWithCapacity:[oldArray count] / 2];
    NSMutableArray *newIndexes = [NSMutableArray arrayWithCapacity:[oldArray count] / 2];

    // Adding the boundaries prevents calculations at boundaries from being
    // special cases and thus simplifies things.
    [oldIndexes addObject:@(-1)];
    [newIndexes addObject:@(-1)];

    for (i = 0; i < oldCount; ++i) {
        j = [newArray indexOfObject:oldArray[i]];
        if (j != NSNotFound) {
            [oldIndexes addObject:@(i)];
            [newIndexes addObject:@(j)];
        }
    }

    [oldIndexes addObject:@(oldCount)];
    [newIndexes addObject:@(newCount)];

    NSInteger indexCount = [oldIndexes count];

    // Value in array is the new index while the array index is old index.
    NSMutableArray *newOrder = [NSMutableArray arrayWithCapacity:indexCount];
    for (i = 0; i < indexCount; ++i)
        [newOrder addObject:@(i)];

    BOOL isOrdered;
    do {
        isOrdered = YES;
        for (i = 1; i < indexCount; ++i) {
            if ([newIndexes[[newOrder[i] integerValue]] integerValue] < [newIndexes[[newOrder[i - 1] integerValue]] integerValue]) {
                [newOrder exchangeObjectAtIndex:i withObjectAtIndex:i - 1];
                isOrdered = NO;
            }
        }
    } while (!isOrdered);

    NSMutableArray *deletes = [NSMutableArray arrayWithCapacity:indexCount - 1];
    for (i = 1; i < indexCount; ++i) {
        from  = [oldIndexes[i - 1] integerValue] + 1;
        count = [oldIndexes[i] integerValue] - from;
        if (count > 0) {
            [deletes addObject:@[@(from), @(count)]];
#ifdef DEBUG
            NSLog(@"delete %d at %d", count, from);
#endif
        }
    }

    NSMutableArray *moves = [NSMutableArray arrayWithCapacity:indexCount - 2];
    for (i = 1; i < indexCount - 1; ++i) {
        from = [oldIndexes[i] integerValue];
        to   = [newIndexes[i] integerValue];
        if (from != to/* && ![moves containsObject:@[@(to), @(from)]]*/) {
            [moves addObject:@[@(from), @(to)]];
#ifdef DEBUG
            NSLog(@"move %d to %d", from, to);
#endif
        }
    }

    NSMutableArray *inserts = [NSMutableArray arrayWithCapacity:indexCount - 2];
    for (i = 1; i < indexCount; ++i) {
        from  = [newIndexes[[newOrder[i - 1] integerValue]] integerValue] + 1;
        count = [newIndexes[[newOrder[i] integerValue]] integerValue] - from;
        if (count > 0) {
            [inserts addObject:@[@(from), @(count)]];
#ifdef DEBUG
            NSLog(@"insert %d at %d", count, from);
#endif
        }
    }

    return @{
    PHFArrayComparatorDeletesKey : deletes,
    PHFArrayComparatorMovesKey   : moves,
    PHFArrayComparatorInsertsKey : inserts
    };
}

@end
