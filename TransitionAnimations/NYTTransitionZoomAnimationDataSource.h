//
//  NYTTransitionZoomAnimationDataSource.h
//  TransitionAnimations
//
//  Created by Logan Moseley on 3/19/15.
//  Copyright (c) 2015 CalamitySoft. All rights reserved.
//

@import Foundation;

@protocol NYTTransitionZoomAnimationDataSource <NSObject>

- (CGRect)transitionRectForTransitionContext:(id<UIViewControllerContextTransitioning>)transitionContext;

@end
