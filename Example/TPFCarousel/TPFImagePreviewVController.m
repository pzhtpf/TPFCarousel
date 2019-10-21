//
//  TPFImagePreviewVController.m
//  TPFCarousel_Example
//
//  Created by Roc.Tian on 2019/10/21.
//  Copyright © 2019 pzhtpf. All rights reserved.
//

#import "TPFImagePreviewVController.h"
#import <TPFCarousel/TPFCarousel.h>

@interface TPFImagePreviewVController ()

@property (strong, nonatomic) TPFCarousel *carousel;
@property (strong, nonatomic) NSArray *images;
@property (nonatomic) int selectedIndex;

@end

@implementation TPFImagePreviewVController
- (id)initWithImages:(NSArray *)images selectedIndex:(int)selectedIndex {
    self = [super init];
    if (self) {
        _images = images;
        _selectedIndex = selectedIndex;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];

    self.carousel = [[TPFCarousel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64)];
    [self.view addSubview:self.carousel];
    self.carousel.selectedIndex = 1;
    self.carousel.layer.cornerRadius = 10;
    self.carousel.contentMode = UIViewContentModeScaleAspectFill;
    self.carousel.space = 5;
    self.carousel.contentMode = UIViewContentModeScaleAspectFit;
    //    self.carousel.autoplay = YES;
    self.carousel.interval = 5;
    self.carousel.indicatorDots = YES;
    self.carousel.zoom = YES;
    self.carousel.selectedIndex = self.selectedIndex;
    self.carousel.images = self.images;

    [self.view addSubview:self.carousel];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
