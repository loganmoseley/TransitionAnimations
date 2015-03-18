//
//  CALTransitionAnimator.m
//  TransitionAnimations
//
//  Created by Logan Moseley on 3/18/15.
//  Copyright (c) 2015 CalamitySoft. All rights reserved.
//

#import "CALTransitionAnimator.h"

@implementation CALTransitionAnimator

// This is used for percent driven interactive transitions, as well as for container controllers that have companion animations that might need to
// synchronize with the main animation.
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.isDismissing) {
        [self animateDismissal:transitionContext];
    }
    else {
        [self animatePresentation:transitionContext];
    }
}

- (void)animatePresentation:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *source      = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *destination = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView           *container   = [transitionContext containerView];
    
    destination.view.transform = CGAffineTransformMakeScale(0.5, 0.5);
    [container addSubview:destination.view];
    [source beginAppearanceTransition:NO animated:YES];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                     animations:^{
                         destination.view.transform = CGAffineTransformIdentity;
                         source.view.transform = CGAffineTransformMakeScale(2, 2);
                     } completion:^(BOOL finished) {
                         [source endAppearanceTransition];
                         [transitionContext completeTransition:YES];
                     }];
}

// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateDismissal:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *source      = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *destination = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView           *container   = [transitionContext containerView];
    
    destination.view.transform = CGAffineTransformMakeScale(2, 2);
    [destination beginAppearanceTransition:YES animated:YES];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                     animations:^{
                         destination.view.transform = CGAffineTransformIdentity;
                         source.view.transform = CGAffineTransformMakeScale(0.5, 0.5);
                     } completion:^(BOOL finished) {
                         [destination endAppearanceTransition];
                         [source.view removeFromSuperview];
                         [transitionContext completeTransition:YES];
                     }];
}

@end
