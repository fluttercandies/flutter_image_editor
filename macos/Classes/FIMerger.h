//
//  FIMerger.h
//  GPUImage
//
//  Created by Caijinglong on 2020/5/27.
//

#import <Foundation/Foundation.h>
#import "FIConvertUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface FIMerger : NSObject

@property(nonatomic, strong) FIMergeOption *option;

- (NSData *)process;

- (NSString *)makeOutputPath;

@end

NS_ASSUME_NONNULL_END
