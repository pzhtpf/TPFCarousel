//
//  TPFImageZoomState.h
//  FBSnapshotTestCase
//
//  Created by Roc.Tian on 2019/10/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TPFImageZoomState : NSObject

@property(nonatomic) float zoomScale ;
@property(nonatomic) CGSize contentSize;
@property(nonatomic) CGPoint contentOffset;
@property(nonatomic) CGPoint center;
@property(nonatomic) CGRect imageFrame;

@end

NS_ASSUME_NONNULL_END
