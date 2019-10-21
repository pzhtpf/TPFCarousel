//
//  TPFRotationViewManager.h
//  FBSnapshotTestCase
//
//  Created by Roc.Tian on 2019/10/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TPFRotationViewManager : NSObject

@property(weak,nonatomic) UIView *targetView;
- (void)rotationView:(float)angle;
-(void)startMotionManager;
-(void)stopMotionManager;

@end

NS_ASSUME_NONNULL_END
