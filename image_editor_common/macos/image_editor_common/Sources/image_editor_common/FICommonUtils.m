//
// Created by jinglong cai on 2022/7/11.
//

#import "FICommonUtils.h"


@implementation FICommonUtils {

}
+ (NSMutableArray *)pointToArray:(CGPoint)point {
    NSMutableArray *arr = [NSMutableArray new];

    [arr addObject:@(point.x)];
    [arr addObject:@(point.y)];

    return arr;
}

+ (CGPoint)arrayToPoint:(NSArray *)arr {
    CGPoint result;

    result.x = [arr[0] doubleValue];
    result.x = [arr[1] doubleValue];

    return result;
}


@end