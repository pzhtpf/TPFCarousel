//
//  TPFPreviewImageView.m
//  SCEPreviewImage
//
//  Created by Roc.Tian on 2018/7/11.
//  Copyright © 2018年 China SCE Property Holdings Co., Ltd. All rights reserved.
//

#import "TPFPreviewImageView.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <Masonry/Masonry.h>

@interface TPFPreviewImageView()

@property(strong,nonatomic) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation TPFPreviewImageView

-(id)init{
    self = [super init];
    if(self){
       [self initView];
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self initView];
    }
    return self;
}
-(void)initView{
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.imageView.contentMode = 1;
    self.imageView.tag = 100;
    self.imageView.clipsToBounds = YES;
    [self addSubview:self.imageView];
}
#pragma mark public API
-(void)restoreZoom{
    self.scrollView.zoomScale = 1.0f;
    self.scrollView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    self.scrollView.contentOffset = CGPointMake(0, 0);
    self.imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    self.imageView.frame = CGRectMake(0,0,self.frame.size.width, self.frame.size.height);
    
    if(_zoomChanged)
        _zoomChanged(self,self.scrollView.zoomScale,self.imageView.center);
}
#pragma mark UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    UIView *subView = _imageView;
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
    
    if(_zoomChanged)
        _zoomChanged(self,self.scrollView.zoomScale,subView.center);
}
-(void)starLoading:(void (^)(BOOL))loadingFinishedBlock{
    self.loadingFinishedBlock = loadingFinishedBlock;
    
//    if(!self.loadingFinished){
//        self.url = _imageObject;
//    }
//    else{
//        if(self.loadingFinishedBlock)
//            self.loadingFinishedBlock(self.loadingFinished);
//    }
    
    self.url = _imageObject;
}
-(void)cancelLoading{
    if(self.url){
        [self.imageView yy_cancelCurrentImageRequest];
    }
    
    if(self.loadingFinishedBlock)
        self.loadingFinishedBlock(self.loadingFinished);
}
#pragma mark setter
-(void)setZoom:(Boolean)zoom{
    _zoom = zoom;
      if(self.zoom){
         [self addSubview:self.scrollView];
         [self.scrollView addSubview:self.imageView];
     }
     else{
         [self addSubview:self.imageView];
         [_scrollView removeFromSuperview];
     }
}
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    self.scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
//    self.imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}
-(void)setImageObject:(id)imageObject{
    _imageObject = imageObject;
    if([_imageObject isKindOfClass:[NSString class]]){
        if([_imageObject hasPrefix:@"http"]){
            self.activityIndicatorView.hidden = NO;
            [self.activityIndicatorView startAnimating];
//            self.url = _imageObject;
        }
        else if([_imageObject hasPrefix:@"data:image"]){    // 不是图片链接的话，他就是一个图片的具体数据，data:image/png;base64,iVBORw0KGgoAA.......
            NSArray *array = [_imageObject componentsSeparatedByString:@","];
            if(array.count==2){
                NSString *dataString = array[1];
                NSData *decodedImageData   = [[NSData alloc] initWithBase64EncodedString:dataString options:0];
                UIImage *decodedImage      = [UIImage imageWithData:decodedImageData];
                self.imageView.image = decodedImage;
                self.loadingFinished = true;
                if(self.loadingFinishedBlock)
                    self.loadingFinishedBlock(self.loadingFinished);
            }
        }
    }
    else if([_imageObject isKindOfClass:[UIImage class]]){
        self.imageView.image = _imageObject;
        self.loadingFinished = true;
        if(_loadingFinishedBlock)
            self.loadingFinishedBlock(self.loadingFinished);
    }
}
-(void)setUrl:(NSString *)url{
    
    __weak typeof(self) weakSelf = self;
//    url = [NSString stringWithFormat:@"%@?x-oss-process=image/resize,w_1125/quality,Q_90",url];
    NSString *imgURL = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self.imageView yy_setImageWithURL:[NSURL URLWithString:imgURL] placeholder:nil options:YYWebImageOptionSetImageWithFadeAnimation progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
        return image;
    } completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        
        if(image){
            weakSelf.activityIndicatorView.hidden = YES;
            [weakSelf.activityIndicatorView stopAnimating];
            weakSelf.loadingFinished = true;
        }
        else
            weakSelf.loadingFinished = false;
        
        if(weakSelf.loadingFinishedBlock)
            weakSelf.loadingFinishedBlock(weakSelf.loadingFinished);
    }];
}
#pragma mark getter
-(UIScrollView *)scrollView{
    if(!_scrollView){
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
              
       _scrollView.maximumZoomScale = 3;
       _scrollView.multipleTouchEnabled = YES;
       _scrollView.alwaysBounceVertical = NO;
       _scrollView.delegate = self;

    }
    return _scrollView;
}
-(UIActivityIndicatorView *)activityIndicatorView{
    if(!_activityIndicatorView){
        _activityIndicatorView = [[UIActivityIndicatorView alloc] init];
        _activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        [self addSubview:_activityIndicatorView];
        [_activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self);
        }];
    }
    return  _activityIndicatorView;
}
@end
