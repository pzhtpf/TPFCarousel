//
//  TPFCarousel.h
//  FBSnapshotTestCase
//
//  Created by Roc.Tian on 2019/10/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TPFCarousel : UIView

/* 图片数组，可以为超链接，也可以是UIImage */
@property(strong,nonatomic) NSArray *images;
/* 当前选中的图片下标记，从0开始 */
@property(nonatomic) int selectedIndex;
/* 滑动时两个图片之间的距离 */
@property(nonatomic) int space;
/* 允许轮播 */
@property(nonatomic) BOOL allowCircular;

@end

NS_ASSUME_NONNULL_END
