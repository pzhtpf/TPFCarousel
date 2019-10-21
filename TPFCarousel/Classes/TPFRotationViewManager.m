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
@property (nonatomic) Boolean isRoateFinished;

@end

@implementation TPFRotationViewManager

-(id)init{
    self = [super init];
    if(self){
        self.isRoateFinished = true;
    }
    return self;
}

- (void)startMotionManager {
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
                    [self rotationView:-M_PI_2];
                }
                if (accelerometerData.acceleration.x < -0.5) { //右横屏
                    [self rotationView:M_PI_2];
                }
            } else {
                if (accelerometerData.acceleration.y < -0.5) { //竖屏
                    [self rotationView:0];
                }
            }
        }];
    } else {
        NSLog(@"不支持陀螺仪");
    }
}
-(void)stopMotionManager{
    [self.motionManager stopAccelerometerUpdates];
}
- (void)rotationView:(float)angle{
    if (angle == self.currectAngle || !self.isRoateFinished) return;

    self.isRoateFinished = false;
    self.currectAngle = angle;

    [UIView animateWithDuration:0.5f animations:^{
        self.targetView.transform = CGAffineTransformMakeRotation(angle);
        [self.targetView layoutIfNeeded];

    } completion:^(BOOL finished) {
        self.isRoateFinished = true;
    }];
}
@end
