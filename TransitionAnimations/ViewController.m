//
//  ViewController.m
//  TransitionAnimations
//
//  Created by Logan Moseley on 3/18/15.
//  Copyright (c) 2015 CalamitySoft. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@end

@implementation ViewController

- (CGRect)transitionRectForTransitionContext:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *transitionView = [self transitionViewForTransitionContext:transitionContext];
    CGRect effectiveFrame = CGRectApplyAffineTransform(transitionView.frame, transitionView.transform);
    return [transitionView.superview convertRect:effectiveFrame toView:nil];
}

- (UIView *)transitionViewForTransitionContext:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.imageView;
}

@end
