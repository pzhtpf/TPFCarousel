//
//  TPFViewController.m
//  TPFCarousel
//
//  Created by pzhtpf on 10/18/2019.
//  Copyright (c) 2019 pzhtpf. All rights reserved.
//

#import "TPFViewController.h"
#import <TPFCarousel/TPFCarousel.h>
#import "TPFImagePreviewVController.h"

@interface TPFViewController ()

@property(strong,nonatomic) TPFCarousel *carousel;
@property(strong,nonatomic) TPFImagePreviewVController *imagePreviewVController;


@end

@implementation TPFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
   NSArray *images = @[
      @"http://uploads.5068.com/allimg/141209/39-1412091J334.jpg",
      @"http://b-ssl.duitang.com/uploads/blog/201307/22/20130722110124_vUCG4.jpeg",
      @"http://uploads.5068.com/allimg/141211/39-1412111Q305.jpg",
      @"http://img.eeyy.com/uploadfile/2013/0509/20130509032321472.jpg"
    ];
    
    __weak typeof(self) weakSelf = self;
    
    self.carousel = [[TPFCarousel alloc] initWithFrame:CGRectMake(50, 300, 300, 200)];
    [self.view addSubview:self.carousel];
    self.carousel.selectedIndex = 1;
    self.carousel.layer.cornerRadius = 10;
    self.carousel.contentMode = UIViewContentModeScaleAspectFill;
    self.carousel.space = 5;
//    self.carousel.autoplay = YES;
    self.carousel.interval = 5;
    self.carousel.indicatorDots = YES;
    self.carousel.zoom = YES;
    self.carousel.allowCircular = false;
    self.carousel.selectedIndexChanged = ^(int selectedIndexChanged){
//        NSLog(@"回调后的选中：%d",selectedIndexChanged);
    };
    self.carousel.itemClicked = ^(int selectedIndexChanged){
        NSLog(@"选中：%d",selectedIndexChanged);
        weakSelf.imagePreviewVController = [[TPFImagePreviewVController alloc] initWithImages:images selectedIndex:selectedIndexChanged];
        [weakSelf presentViewController:weakSelf.imagePreviewVController  animated:YES completion:^{
            
        }];
    };
    
    self.carousel.images = images;
    
//        self.carousel.images = @[
//          @"http://uploads.5068.com/allimg/141209/39-1412091J334.jpg"
//        ];
    
    
//        self.carousel.images = @[
//          @"http://uploads.5068.com/allimg/141209/39-1412091J334.jpg",
//          @"http://b-ssl.duitang.com/uploads/blog/201307/22/20130722110124_vUCG4.jpeg"
//        ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
