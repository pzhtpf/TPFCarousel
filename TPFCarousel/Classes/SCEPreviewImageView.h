//
//  SCEPreviewImageView.h
//  SCEPreviewImage
//
//  Created by Roc.Tian on 2018/7/11.
//  Copyright © 2018年 China SCE Property Holdings Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCEPreviewImageView;

typedef void(^ZoomChanged)(SCEPreviewImageView *previewImageView,float scale,CGPoint centerPoint);
typedef void(^LoadingFinishedBlock)(BOOL loadingFinished);

@interface SCEPreviewImageView : UIView<UIScrollViewDelegate>

@property(strong,nonatomic) id imageObject;
@property(strong,nonatomic) NSString *url;
@property(nonatomic) int index;

@property(strong,nonatomic) UIScrollView *scrollView;
@property(strong,nonatomic) UIImageView *imageView;

@property(nonatomic) ZoomChanged zoomChanged;

-(void)starLoading:(void(^)(BOOL loadingFinished)) loadingFinishedBlock;
-(void)cancelLoading;
@property(nonatomic) BOOL loadingFinished;
@property(nonatomic) LoadingFinishedBlock  loadingFinishedBlock;

-(void)restoreZoom;
@end
