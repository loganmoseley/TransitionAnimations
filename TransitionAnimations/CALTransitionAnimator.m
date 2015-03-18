//
//  CALTransitionAnimator.m
//  TransitionAnimations
//
//  Created by Logan Moseley on 3/18/15.
//  Copyright (c) 2015 CalamitySoft. All rights reserved.
//

#import "CALTransitionAnimator.h"
#import "ViewController.h"
#import "CALImageViewController.h"

@implementation CALTransitionAnimator

// This is used for percent driven interactive transitions, as well as for container controllers that have companion animations that might need to
// synchronize with the main animation.
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 1;
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
    
    // iOS 8 doesn't use a rotation transform, but it does get the bounds of the destination wrong for landscape
    // (while container is right!).
    destination.view.bounds = container.bounds;
    
    [destination.view layoutIfNeeded];
    CGAffineTransform originalDestinationTransform = destination.view.transform;
    CGAffineTransform originalSourceTransform = source.view.transform;
    
    CGRect fromRect = [(ViewController *)source transitionFromRect];
    CGRect toRect = [(CALImageViewController *)destination transitionToRect];
    CGAffineTransform sourceToDestinationTransform = CGAffineScaleTransformFromRectToRect(fromRect, toRect);
    
    destination.view.alpha = 0;
    destination.view.transform = CGAffineTransformInvert(sourceToDestinationTransform);
    [container addSubview:destination.view];
    [source beginAppearanceTransition:NO animated:YES];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         destination.view.alpha = 1;
                         destination.view.transform = originalDestinationTransform;
                         source.view.transform = CGAffineTransformConcat(originalSourceTransform, sourceToDestinationTransform);
                     } completion:^(BOOL finished) {
                         source.view.transform = originalSourceTransform;
                         [source endAppearanceTransition];
                         [transitionContext completeTransition:YES];
                     }];
}

// This method can only be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateDismissal:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *source      = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *destination = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView           *container   = [transitionContext containerView];
    
//    destination.view.transform = CGAffineTransformMakeScale(3, 3);
    [destination beginAppearanceTransition:YES animated:YES];
    [container addSubview:destination.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                     animations:^{
                         source.view.alpha = 0;
//                         destination.view.transform = CGAffineTransformIdentity;
//                         source.view.transform = CGAffineTransformMakeScale(0.5, 0.5);
                     } completion:^(BOOL finished) {
                         [destination endAppearanceTransition];
                         [source.view removeFromSuperview];
                         [transitionContext completeTransition:YES];
                     }];
}

// http://stackoverflow.com/a/14764286/1621334 and Danny Zlobinsky
// does not consider rotation
CG_INLINE CGAffineTransform CGAffineScaleTransformFromRectToRect(CGRect fromRect, CGRect toRect) {
    CGSize scale = CGSizeMake(toRect.size.width/fromRect.size.width, toRect.size.height/fromRect.size.height);
    CGPoint translation = CGPointMake(CGRectGetMidX(toRect) - CGRectGetMidX(fromRect), CGRectGetMidY(toRect) - CGRectGetMidY(fromRect));
    return CGAffineTransformMake(scale.width, 0, 0, scale.height, translation.x, translation.y);
}

@end
