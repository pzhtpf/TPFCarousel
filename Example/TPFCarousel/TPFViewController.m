//
//  TPFViewController.m
//  TPFCarousel
//
//  Created by pzhtpf on 10/18/2019.
//  Copyright (c) 2019 pzhtpf. All rights reserved.
//

#import "TPFViewController.h"
#import <TPFCarousel/TPFCarousel.h>

@interface TPFViewController ()

@property(strong,nonatomic) TPFCarousel *carousel;

@end

@implementation TPFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.carousel = [[TPFCarousel alloc] initWithFrame:CGRectMake(100, 300, self.view.frame.size.width-200, 300)];
    [self.view addSubview:self.carousel];
    
    self.carousel.images = @[
      @"http://uploads.5068.com/allimg/141209/39-1412091J334.jpg",
      @"http://b-ssl.duitang.com/uploads/blog/201307/22/20130722110124_vUCG4.jpeg",
      @"http://uploads.5068.com/allimg/141211/39-1412111Q305.jpg",
      @"http://img.eeyy.com/uploadfile/2013/0509/20130509032321472.jpg"
    ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
