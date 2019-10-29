//
//  TPFPreviewImageView.h
//  SCEPreviewImage
//
//  Created by Roc.Tian on 2018/7/11.
//  Copyright © 2018年 China SCE Property Holdings Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPFPreviewImageView;

typedef void(^ZoomChanged)(TPFPreviewImageView *previewImageView,float scale,CGPoint centerPoint);
typedef void(^LoadingFinishedBlock)(BOOL loadingFinished);

@interface TPFPreviewImageView : UIView<UIScrollViewDelegate>

/* 图片对象，可能是图片链接，也可能是UIImage，也可能是图片Base64数据 */
@property(strong,nonatomic) id imageObject;
/* 图片链接 */
@property(strong,nonatomic) NSString *url;
/* 唯一标记 */
@property(nonatomic) int index;
/* 占位图片 */
@property(strong,nonatomic) UIImage *placeholderImage;


@property(strong,nonatomic) UIScrollView *scrollView;
@property(strong,nonatomic) UIImageView *imageView;

@property(nonatomic) ZoomChanged zoomChanged;
@property(nonatomic) Boolean zoom;

-(void)starLoading:(void(^)(BOOL loadingFinished)) loadingFinishedBlock;
-(void)cancelLoading;
@property(nonatomic) BOOL loadingFinished;
@property(nonatomic) LoadingFinishedBlock  loadingFinishedBlock;

-(void)restoreZoom;
@end
