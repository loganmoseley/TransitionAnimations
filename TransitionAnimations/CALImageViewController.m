//
//  CALImageViewController.m
//  TransitionAnimations
//
//  Created by Logan Moseley on 3/18/15.
//  Copyright (c) 2015 CalamitySoft. All rights reserved.
//

#import "CALImageViewController.h"

@interface CALImageViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@end

@implementation CALImageViewController

- (CGRect)transitionRectForTransitionContext:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *transitionView = [self transitionViewForTransitionContext:transitionContext];
    CGRect effectiveFrame = CGRectApplyAffineTransform(transitionView.frame, transitionView.transform);
    return [transitionView.superview convertRect:effectiveFrame toView:nil];
}

- (UIView *)transitionViewForTransitionContext:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.imageView;
}

@end
