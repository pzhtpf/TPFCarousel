//
//  TPFCarousel.h
//  FBSnapshotTestCase
//
//  Created by Roc.Tian on 2019/10/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SelectedIndexChanged)(int selectedIndex);

@interface TPFCarousel : UIView

/* 图片数组，可以为超链接，也可以是UIImage */
@property(strong,nonatomic) NSArray *images;
/* 当前选中的图片下标记，从0开始 */
@property(nonatomic) int selectedIndex;
/* 滑动时两个图片之间的距离 */
@property(nonatomic) int space;
/* 允许轮播 */
@property(nonatomic) BOOL allowCircular;
/* 内容模式 */
@property(nonatomic) UIViewContentMode contentMode;
/* 是否显示面板指示点  默认false */
@property(nonatomic) Boolean indicatorDots;
/* 指示点颜色  默认rgba(0, 0, 0, 0.3) */
@property(strong,nonatomic) UIColor *indicatorColor ;
/* 当前选中的指示点颜色  默认0x000000 */
@property(strong,nonatomic) UIColor *indicatorActiveColor ;
/* 是否自动切换   默认false */
@property(nonatomic) Boolean autoplay;
/* 自动切换时间间隔   默认5s */
@property(nonatomic) float interval;
/* 滑动动画时长  默认0.5s */
@property(nonatomic) float duration;
/* 滑动结束后的回调 */
@property(nonatomic) SelectedIndexChanged selectedIndexChanged;

@end

NS_ASSUME_NONNULL_END
