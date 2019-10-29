//
//  TPFCarousel.m
//  FBSnapshotTestCase
//
//  Created by Roc.Tian on 2019/10/18.
//

#import "TPFCarousel.h"
#import "TPFPreviewImageView.h"
#import "TPFImageZoomState.h"
#import "TPFRotationViewManager.h"

@interface TPFCarousel ()<UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray<TPFPreviewImageView *> *imageViewArray;
@property (nonatomic) float width;
@property (nonatomic) float height;
@property (nonatomic) float mainOriginX;
@property (nonatomic) float lastContentOffsetX;
@property (nonatomic) ScrollDirection scrollDirection;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSMutableDictionary<NSString *, TPFImageZoomState *> *imageZoomStates;
@property (strong, nonatomic) TPFRotationViewManager *rotationViewManager;
@property (nonatomic) Boolean isExchanging;

@end

@implementation TPFCarousel
- (void)dealloc {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    self.width = self.frame.size.width;
    self.height = self.frame.size.height;

    self.clipsToBounds = YES;
    self.layer.masksToBounds = YES;
    self.userInteractionEnabled = YES;
    _indicatorColor = [UIColor colorWithRed:215 / 255.0 green:215 / 255.0 blue:215 / 255.0 alpha:0.67];
    _indicatorActiveColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];

    [self addSubview:self.scrollView];

    self.interval = 5;
    self.allowCircular = true;

    _imageViewArray = [NSMutableArray new];
    _imageZoomStates = [NSMutableDictionary new];

    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemClickd:)]];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
//    NSLog(@"scrollViewWillBeginDecelerating");
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    NSLog(@"scrollViewWillBeginDragging");
    [self stopAutoScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    NSLog(@"scrollViewDidEndDragging");

    if ([scrollView.panGestureRecognizer translationInView:scrollView.superview].x > 0) {
        // handle dragging to the right
        NSLog(@"右");
        self.scrollDirection = ScrollDirectionRight;
    } else {
        // handle dragging to the left
        NSLog(@"左");
        self.scrollDirection = ScrollDirectionLeft;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self exchangePosition:scrollView];
    self.autoplay = _autoplay;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
//    NSLog(@"scrollViewDidEndScrollingAnimation");
    [self exchangePosition:scrollView];
}

#pragma mark private method
-(BOOL)getAllowCircularStatus{
    if(self.allowCircular)
        return self.allowCircular;
    else{
        if((self.scrollDirection == ScrollDirectionLeft && self.selectedIndex==self.images.count-1) ||
           (self.scrollDirection == ScrollDirectionRight && self.selectedIndex==0))
            return false;
        
        return true;
    }
}
-(BOOL)getAllowChangeStatus{
    if(self.allowCircular)
        return self.allowCircular;
    else{
        if((self.scrollDirection == ScrollDirectionLeft && self.selectedIndex>self.images.count-2) ||
           (self.scrollDirection == ScrollDirectionRight && self.selectedIndex<1))
            return false;
        
        return true;
    }
}
- (void)exchangePosition:(UIScrollView *)scrollView {
    
    /*首先判断是否滑动了一屏，是否需要交换*/
    float scrollDistance = fabs(scrollView.contentOffset.x-self.lastContentOffsetX);
    NSLog(@"滑动距离：%f",scrollDistance);
    if(scrollDistance<self.width/2+self.space){
        return;
    }
    
//    if(self.scrollView.contentOffset.x == self.width+self.space)
//        return;
    
    [self getSelectedIndex];
    [self exchangingPosition];
    self.scrollDirection = ScrollDirectionNone;

    if (_selectedIndexChanged) _selectedIndexChanged(_selectedIndex);
}
- (void)exchangingPosition{
    
    if(![self getAllowChangeStatus]){
        self.lastContentOffsetX = self.scrollView.contentOffset.x;
        return;
    }
    
    [self syncImageZoomState];
    [self loadMainImage];
    [self resetImageZoomState];
}
- (void)getSelectedIndex {
    
    if(![self getAllowCircularStatus]){
        return;
    }
    
    if (self.scrollDirection == ScrollDirectionRight) self.selectedIndex--;
    else if (self.scrollDirection == ScrollDirectionLeft) self.selectedIndex++;

    self.selectedIndex = self.selectedIndex > (int)self.images.count - 1 ? 0 : self.selectedIndex;
    self.selectedIndex = self.selectedIndex < 0 ? (int)self.images.count - 1 : self.selectedIndex;

    _pageControl.currentPage = self.selectedIndex;
    NSLog(@"当前选中：%d", self.selectedIndex);
}

- (void)loadMainImage {
    [self.imageViewArray enumerateObjectsUsingBlock:^(TPFPreviewImageView *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if (obj.frame.origin.x == self.mainOriginX) {
            int index = MIN(self.selectedIndex, (int)self.images.count - 1);
            index = MAX(0, index);
            obj.imageObject = self.images[index];
            __weak typeof(self) weakSelf = self;
            [obj starLoading:^(BOOL loadingFinished) {
                
                weakSelf.scrollView.contentOffset = CGPointMake(weakSelf.width + weakSelf.space, 0);
                self.lastContentOffsetX = self.scrollView.contentOffset.x;
                [weakSelf loadOtherImage];
                
            }];
        }
    }];
}

- (void)loadOtherImage {
    [self.imageViewArray enumerateObjectsUsingBlock:^(TPFPreviewImageView *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        Boolean isNeedLoad = self.scrollView.contentOffset.x == (self.width+self.space);
        if (obj.frame.origin.x == 0 && isNeedLoad) {
            int left = self.selectedIndex - 1;
            left = left < 0 ? (int)self.images.count - 1 : left;
            if (left >= 0 && left < self.images.count) {
                obj.imageObject = self.images[left];
                [obj starLoading:^(BOOL loadingFinished) {
                }];
            }
        } else if (obj.frame.origin.x == (self.width + self.space) * 2 && isNeedLoad) {
            int right = self.selectedIndex + 1;
            right = right > (int)self.images.count - 1 ? 0 : right;
            if (right >= 0 && right < self.images.count) {
                obj.imageObject = self.images[right];
                [obj starLoading:^(BOOL loadingFinished) {
                }];
            }
        }
    }];
}

- (void)autoScroll {
    if (self.images.count > 1 && self.interval > 0 && self.autoplay) {
        self.scrollDirection = ScrollDirectionLeft;
        [self.scrollView setContentOffset:CGPointMake((self.width + self.space) * 2, 0) animated:YES];
    } else [self stopAutoScroll];
}

- (void)startAutoScroll {
    [self stopAutoScroll];
    if (_interval > 0) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:self.interval target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
        NSRunLoop *runLoop = [NSRunLoop mainRunLoop];
        [runLoop addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopAutoScroll {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)syncImageZoomState {
    if (!self.zoom) return;

    [self.imageViewArray enumerateObjectsUsingBlock:^(TPFPreviewImageView *previewImageView, NSUInteger idx, BOOL *_Nonnull stop) {
            TPFImageZoomState *imageZoomState = [self.imageZoomStates valueForKey:previewImageView.imageObject];

            if (previewImageView.scrollView.zoomScale != 1) {
                if (!imageZoomState) imageZoomState = [TPFImageZoomState new];

                imageZoomState.zoomScale = previewImageView.scrollView.zoomScale;
                imageZoomState.contentSize = previewImageView.scrollView.contentSize;
                imageZoomState.contentOffset = previewImageView.scrollView.contentOffset;
                CGRect imageFrame = previewImageView.imageView.frame;
                imageZoomState.imageFrame = CGRectMake(0, 0, imageFrame.size.width, imageFrame.size.height);
                imageZoomState.center = CGPointMake(previewImageView.imageView.center.x, previewImageView.imageView.center.y);
                [self.imageZoomStates setValue:imageZoomState forKey:previewImageView.imageObject];
            } else if (imageZoomState) {
                [self.imageZoomStates removeObjectForKey:previewImageView.imageObject];
            }
    }];
}

- (void)resetImageZoomState {
    if (!self.zoom) return;

    [self.imageViewArray enumerateObjectsUsingBlock:^(TPFPreviewImageView *tempPreviewImageView, NSUInteger idx, BOOL *_Nonnull stop) {
        TPFImageZoomState *imageZoomState = [self.imageZoomStates valueForKey:tempPreviewImageView.imageObject];
        if (imageZoomState) {
            tempPreviewImageView.scrollView.zoomScale = imageZoomState.zoomScale;
            tempPreviewImageView.scrollView.contentSize = imageZoomState.contentSize;
            tempPreviewImageView.scrollView.contentOffset = imageZoomState.contentOffset;
            tempPreviewImageView.imageView.center = imageZoomState.center;
            tempPreviewImageView.imageView.frame = imageZoomState.imageFrame;
        } else {
            [tempPreviewImageView restoreZoom];
        }
    }];
}

- (void)itemClickd:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (_itemClicked) _itemClicked(self.selectedIndex);
}

#pragma mark setter
- (void)setImages:(NSArray *)images {
    _images = images;
    _pageControl.numberOfPages = _images.count;

    [_imageViewArray enumerateObjectsUsingBlock:^(TPFPreviewImageView *obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [_imageViewArray removeAllObjects];

    if (!_images || _images.count == 0) {
        return;
    } else if (_images.count == 1) {
        self.allowCircular = false;
        self.mainOriginX = 0;
        self.lastContentOffsetX = self.mainOriginX;
        [self getImageView:0];
        [self loadMainImage];
    } else {
        for (int i = 0; i < 3; i++) {
            [self getImageView:i];
        }
        self.mainOriginX = self.width + self.space;
        [self.scrollView setContentSize:CGSizeMake((self.width + self.space) * 3, self.height)];
        self.scrollView.contentOffset = CGPointMake(self.width + self.space, 0);
        self.lastContentOffsetX = self.mainOriginX;
        [self loadMainImage];
    }

    _pageControl.currentPage = self.selectedIndex;
}

- (void)setSpace:(int)space {
    _space = space;
    self.scrollView.frame = CGRectMake(0, 0, self.width + self.space, self.height);
}

- (void)setAutoplay:(Boolean)autoplay {
    _autoplay = autoplay;
    if (_autoplay) {
        [self startAutoScroll];
        _allowCircular = true;
    } else {
        [self stopAutoScroll];
    }
}
-(void)setAllowCircular:(BOOL)allowCircular{
    if(_autoplay)
        _allowCircular = true;
    else
        _allowCircular = allowCircular;
}
- (void)setInterval:(float)interval {
    _interval = interval;
    [self startAutoScroll];
}

- (void)setIndicatorDots:(Boolean)indicatorDots {
    _indicatorDots = indicatorDots;
    if (_indicatorDots) {
        [self addSubview:self.pageControl];
    } else {
        [_pageControl removeFromSuperview];
    }
}

- (void)setIndicatorColor:(UIColor *)indicatorColor {
    _indicatorColor = indicatorColor;
    _pageControl.pageIndicatorTintColor = _indicatorColor;
}

- (void)setIndicatorActiveColor:(UIColor *)indicatorActiveColor {
    _indicatorActiveColor = indicatorActiveColor;
    _pageControl.currentPageIndicatorTintColor = _indicatorActiveColor;
}

- (void)setZoom:(Boolean)zoom {
    _zoom = zoom;
    [self.imageViewArray enumerateObjectsUsingBlock:^(TPFPreviewImageView *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        obj.zoom = _zoom;
    }];
}

- (void)setAllowGravityRotate:(Boolean)allowGravityRotate {
    _allowGravityRotate = allowGravityRotate;
    if (_allowGravityRotate) {
        [self.rotationViewManager startMotionManager];
    } else {
        [_rotationViewManager stopMotionManager];
    }
}

#pragma mark getter
- (TPFPreviewImageView *)getImageView:(int)index {
    TPFPreviewImageView *imageView = [[TPFPreviewImageView alloc] initWithFrame:CGRectMake(index * (self.width + self.space), 0, self.width, self.height)];
    imageView.backgroundColor = [UIColor clearColor];

    imageView.index = index;
    imageView.imageView.contentMode = self.contentMode;
    imageView.zoom = self.zoom;
    imageView.placeholderImage = self.placeholderImage;
    
    imageView.tag = index;
    
    switch (index) {
        case 0:
            imageView.backgroundColor = [UIColor redColor];
            break;
        case 1:
            imageView.backgroundColor = [UIColor greenColor];
            break;
        case 2:
            imageView.backgroundColor = [UIColor blueColor];
            break;
            
        default:
            break;
    }

    [self.scrollView addSubview:imageView];
    [self.imageViewArray addObject:imageView];

    return imageView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width + self.space, self.height)];

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

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        float pageControlWidth = self.width;
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((self.width - pageControlWidth) / 2, self.height - 30, pageControlWidth, 20)];
        _pageControl.currentPage = self.selectedIndex;
        _pageControl.pageIndicatorTintColor = _indicatorColor;
        _pageControl.currentPageIndicatorTintColor = _indicatorActiveColor;
    }
    return _pageControl;
}

- (TPFRotationViewManager *)rotationViewManager {
    if (!_rotationViewManager) {
        _rotationViewManager = [[TPFRotationViewManager alloc] init];
        _rotationViewManager.targetView = self;
    }
    return _rotationViewManager;
}

@end
