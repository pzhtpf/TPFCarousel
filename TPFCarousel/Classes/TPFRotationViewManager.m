//
//  TPFRotationViewManager.m
//  FBSnapshotTestCase
//
//  Created by Roc.Tian on 2019/10/21.
//

#import "TPFRotationViewManager.h"
#import <CoreMotion/CoreMotion.h>

@interface TPFRotationViewManager()

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (nonatomic) float currectAngle;

@end

@implementation TPFRotationViewManager

-(id)init{
    self = [super init];
    if(self){
        [self intiMotionManager];
    }
    return self;
}

- (void)intiMotionManager {
    self.motionManager = [[CMMotionManager alloc]init];
    //判断加速计是否可用
    if ([self.motionManager isAccelerometerAvailable]) {
        // 设置加速计频率
        [self.motionManager setAccelerometerUpdateInterval:0.5];
        //开始采样数据
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
//            NSLog(@"%f---%f",accelerometerData.acceleration.x,accelerometerData.acceleration.y);

            BOOL x = fabs(accelerometerData.acceleration.x) > fabs(accelerometerData.acceleration.y);
            if (x) {  //横屏
                if (accelerometerData.acceleration.x > 0.5) { //左横屏
//                    [self rotationView:-M_PI_2];
                }
                if (accelerometerData.acceleration.x < -0.5) { //右横屏
//                    [self rotationView:M_PI_2];
                }
            } else {
                if (accelerometerData.acceleration.y < -0.5) { //竖屏
//                    [self rotationView:0];
                }
            }
        }];
    } else {
        NSLog(@"不支持陀螺仪");
    }
}

@end
