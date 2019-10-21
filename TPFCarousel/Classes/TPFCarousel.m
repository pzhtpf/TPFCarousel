//
//  TPFCarousel.m
//  FBSnapshotTestCase
//
//  Created by Roc.Tian on 2019/10/18.
//

#import "TPFCarousel.h"
#import "SCEPreviewImageView.h"

@interface TPFCarousel()<UIScrollViewDelegate>

@property(strong,nonatomic) UIScrollView *scrollView;
@property(strong,nonatomic) NSMutableArray<SCEPreviewImageView *> *imageViewArray;
@property(nonatomic) float width;
@property(nonatomic) float height;
@property(nonatomic) float mainOriginX;
@property(strong,nonatomic) NSTimer *timer;

@end

@implementation TPFCarousel
-(void)dealloc{
    if(_timer){
        [_timer invalidate];
        _timer = nil;
    }
        
}
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self initView];
    }
    return self;
}
-(void)initView{
    
    self.width = self.frame.size.width;
    self.height = self.frame.size.height;
    
    self.clipsToBounds = YES;
    self.layer.masksToBounds = YES;
    self.userInteractionEnabled = YES;
    
    [self addSubview:self.scrollView];
    
    self.interval = 5;
    self.allowCircular = true;
    
    _imageViewArray = [NSMutableArray new];
}
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    NSLog(@"scrollViewWillBeginDecelerating");
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    NSLog(@"scrollViewWillBeginDragging");
    [self stopAutoScroll];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self exchangePosition:scrollView];
    self.autoplay = _autoplay;
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    NSLog(@"scrollViewDidEndScrollingAnimation");
    [self exchangePosition:scrollView];
}
#pragma mark private method
-(void)exchangePosition:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x == 0) {
          [self.imageViewArray enumerateObjectsUsingBlock:^(SCEPreviewImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
               if(obj.frame.origin.x==0){
                   obj.frame = CGRectMake(self.width + self.space, 0, self.width, self.height);
               }
               else if(obj.frame.origin.x==self.width + self.space){
                   obj.frame = CGRectMake(0, 0, self.width, self.height);
               }
           }];
       }
       else if (scrollView.contentOffset.x == (self.width + self.space) * 2) {
           [self.imageViewArray enumerateObjectsUsingBlock:^(SCEPreviewImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
               if(obj.frame.origin.x==self.width + self.space){
                   obj.frame = CGRectMake((self.width + self.space) * 2, 0, self.width, self.height);
               }
               else if(obj.frame.origin.x==(self.width + self.space) * 2){
                   obj.frame = CGRectMake(self.width + self.space, 0, self.width, self.height);
               }
           }];
       }
       scrollView.contentOffset = CGPointMake(self.width + self.space, 0);
       [self getSelectedIndex];
       [self loadMainImage];
       [self loadOtherImage];
    
       if(_selectedIndexChanged)
           _selectedIndexChanged(_selectedIndex);
}
-(void)getSelectedIndex{
    [self.imageViewArray enumerateObjectsUsingBlock:^(SCEPreviewImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       if(obj.frame.origin.x==self.width + self.space){
           [self.images enumerateObjectsUsingBlock:^(id  _Nonnull imageObj, NSUInteger imageObjIdx, BOOL * _Nonnull stop) {
               if([imageObj isKindOfClass:[NSString class]]){
                   NSString *imageUrl = (NSString *)imageObj;
                   if([imageUrl isEqualToString:obj.imageObject]){
                       self.selectedIndex = (int)imageObjIdx;
                       *stop = YES;
                   }
               }
               else if([imageObj isKindOfClass:[UIImage class]]){
                     UIImage *image = (UIImage *)imageObj;
                     if(image == obj.imageObject){
                         self.selectedIndex = (int)imageObjIdx;
                         *stop = YES;
                     }
                 }
           }];
       }
    }];
    
    NSLog(@"当前选中：%d",self.selectedIndex);
}
-(void)loadMainImage{
    [self.imageViewArray enumerateObjectsUsingBlock:^(SCEPreviewImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       if(obj.frame.origin.x == self.mainOriginX){
           int index = MIN(self.selectedIndex, (int)self.images.count-1);
           index = MAX(0, index);
           obj.imageObject = self.images[index];
           [obj starLoading:^(BOOL loadingFinished) {
               
           }];
       }
    }];
}
-(void)loadOtherImage{
    [self.imageViewArray enumerateObjectsUsingBlock:^(SCEPreviewImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
      if(obj.frame.origin.x==0){
          int left = self.selectedIndex - 1;
          left = left<0?(int)self.images.count-1:left;
          if(left>=0 && left<self.images.count){
              obj.imageObject = self.images[left];
              [obj starLoading:^(BOOL loadingFinished) {
                     
              }];
          }
        }
       else if(obj.frame.origin.x==(self.width + self.space)*2){
           int right = self.selectedIndex + 1;
           right = right>(int)self.images.count-1?0:right;
           if(right>=0 && right<self.images.count){
               obj.imageObject = self.images[right];
               [obj starLoading:^(BOOL loadingFinished) {
                   
               }];
           }
       }
    }];
}
-(void)autoScroll{
    if(self.images.count>1 && self.interval>0 && self.autoplay)
        [self.scrollView setContentOffset:CGPointMake((self.width + self.space)*2, 0) animated:YES];
    else
        [self stopAutoScroll];
}
-(void)startAutoScroll{
    [self stopAutoScroll];
     if(_interval>0){
        _timer = [NSTimer scheduledTimerWithTimeInterval:self.interval target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
        NSRunLoop *runLoop = [NSRunLoop mainRunLoop];
        [runLoop addTimer:self.timer forMode:NSRunLoopCommonModes];
     }
}
-(void)stopAutoScroll{
    if(_timer){
        [_timer invalidate];
        _timer = nil;
    }
}
#pragma mark setter
-(void)setImages:(NSArray *)images{
    _images = images;
    
    [_imageViewArray enumerateObjectsUsingBlock:^(SCEPreviewImageView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [_imageViewArray removeAllObjects];
    
    if(!_images || _images.count==0){
        return;
    }
    else if( _images.count==1){
      self.allowCircular = false;
      self.mainOriginX = 0;
      [self getImageView:0];
      [self loadMainImage];
    }
    else{
        
        for (int i=0 ; i<3; i++) {
          [self getImageView:i];
        }
        self.mainOriginX = self.width + self.space;
        [self.scrollView setContentSize:CGSizeMake((self.width + self.space)*3, self.height)];
        self.scrollView.contentOffset = CGPointMake(self.width + self.space, 0);
        [self loadMainImage];
        [self loadOtherImage];
    }
}
-(void)setSpace:(int)space{
    _space = space;
    self.scrollView.frame = CGRectMake(0, 0, self.width+self.space, self.height);
}
-(void)setAutoplay:(Boolean)autoplay{
    _autoplay = autoplay;
    if(_autoplay){
        [self startAutoScroll];
    }
    else{
        [self stopAutoScroll];
    }
}
-(void)setInterval:(float)interval{
    _interval = interval;
    [self startAutoScroll];
}
#pragma mark getter
- (SCEPreviewImageView *)getImageView:(int)index {
    SCEPreviewImageView *imageView = [[SCEPreviewImageView alloc] initWithFrame:CGRectMake(index * (self.width + self.space), 0, self.width, self.height)];
    imageView.backgroundColor = [UIColor clearColor];

    imageView.index = index;
    imageView.imageView.contentMode = self.contentMode;

    [self.scrollView addSubview:imageView];
    [self.imageViewArray addObject:imageView];

    __weak typeof(self) weakSelf = self;
    imageView.zoomChanged = ^(SCEPreviewImageView *previewImageView, float scale, CGPoint centerPoint) {
        [weakSelf.imageViewArray enumerateObjectsUsingBlock:^(SCEPreviewImageView *tempPreviewImageView, NSUInteger idx, BOOL *_Nonnull stop) {
            if (previewImageView.index == tempPreviewImageView.index) {
                tempPreviewImageView.scrollView.zoomScale = scale;
                tempPreviewImageView.scrollView.contentSize = previewImageView.scrollView.contentSize;
                tempPreviewImageView.scrollView.contentOffset = previewImageView.scrollView.contentOffset;
                tempPreviewImageView.imageView.center = centerPoint;
            }
        }];
    };

    return imageView;
}
-(UIScrollView *)scrollView{
    if(!_scrollView){
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width+self.space, self.height)];
         
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.scrollEnabled = YES;
        _scrollView.delegate = self;
    }
    return _scrollView;
}
@end
