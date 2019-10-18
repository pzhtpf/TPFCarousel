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

@end

@implementation TPFCarousel

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
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width+self.space, self.height)];
    [self addSubview:self.scrollView];
    
    self.scrollView.multipleTouchEnabled = YES;
    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    
    self.allowCircular = true;
    
    _imageViewArray = [NSMutableArray new];
}
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

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
    [scrollView scrollRectToVisible:CGRectMake(self.width + self.space, 0, self.width, self.height) animated:NO];

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
    }
    else{
        
    }
}
#pragma mark getter
- (SCEPreviewImageView *)getImageView:(int)index {
    SCEPreviewImageView *imageView = [[SCEPreviewImageView alloc] initWithFrame:CGRectMake(index * (self.width + self.space), 0, self.width, self.height)];
    imageView.backgroundColor = [UIColor clearColor];

    imageView.index = index;

    [self addSubview:imageView];
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
@end
