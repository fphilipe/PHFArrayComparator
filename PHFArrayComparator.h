#import <Foundation/Foundation.h>

extern NSString * const PHFArrayComparatorDeletesKey;
extern NSString * const PHFArrayComparatorMovesKey;
extern NSString * const PHFArrayComparatorInsertsKey;

@interface PHFArrayComparator : NSObject

// Initializes an instance and invokes -compare on it.
+ (NSDictionary *)compareOldArray:(NSArray *)oldArray
                     withNewArray:(NSArray *)newArray;

// Designated initializer. nils are treated as empty arrays.
- (id)initWithOldArray:(NSArray *)oldArray
              newArray:(NSArray *)newArray;

// Returns a dictionary with three keys:
// - PHFArrayComparatorDeletesKey:  An array containing arrays with two
//   NSNumbers, where the first number is the index and the second is the count
//   of items that were deleted from the old array.
// - PHFArrayComparatorMovesKey:  An array containing arrays with two NSNumbers,
//   where the first number is the old index and the second number the new index
//   of a persisted item (i.e. an item that exists in both arrays).
// - PHFArrayComparatorInsertsKey:  An array containing arrays with two
//   NSNumbers, where the first number is the index and the second is the count
//   of items that were inserted in the new array.
- (NSDictionary *)compare;

@end
