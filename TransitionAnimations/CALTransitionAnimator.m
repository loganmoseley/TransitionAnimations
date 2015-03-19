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
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView           *containerView      = [transitionContext containerView];
    
    // iOS 8 doesn't use a rotation transform, but it does get the bounds of the destination wrong for landscape
    // (while container is right!).
    toViewController.view.bounds = containerView.bounds;
    
    [fromViewController.view layoutIfNeeded];
    [toViewController.view layoutIfNeeded];
    CGAffineTransform originalFromTransform = fromViewController.view.transform;
    CGAffineTransform originalToTransform = toViewController.view.transform;
    
    CGRect fromRect = [(ViewController *)fromViewController transitionRectForTransitionContext:transitionContext];
    CGRect toRect = [(CALImageViewController *)toViewController transitionRectForTransitionContext:transitionContext];
    CGAffineTransform fromToToTransform = CGAffineTransformFromRectToRect(fromRect, toRect);
    
    UIView *fromVCSnapshot = [[self class] snapshotViewFromView:fromViewController.view afterScreenUpdates:YES];
    UIView *toVCSnapshot = [[self class] snapshotViewFromView:toViewController.view afterScreenUpdates:YES];
    toVCSnapshot.alpha = 0;
    toVCSnapshot.transform = CGAffineTransformInvert(fromToToTransform);
    [containerView addSubview:fromVCSnapshot];
    [containerView addSubview:toVCSnapshot];
    
    [fromViewController beginAppearanceTransition:NO animated:YES];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         fromVCSnapshot.transform = CGAffineTransformConcat(originalFromTransform, fromToToTransform);
                         toVCSnapshot.alpha = 1;
                         toVCSnapshot.transform = originalToTransform;
                     } completion:^(BOOL finished) {
                         [fromVCSnapshot removeFromSuperview];
                         [toVCSnapshot removeFromSuperview];
                         [containerView addSubview:toViewController.view];
                         [fromViewController endAppearanceTransition];
                         [transitionContext completeTransition:YES];
                     }];
}

// This method can only be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateDismissal:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView           *containerView      = [transitionContext containerView];
    
    [fromViewController.view layoutIfNeeded];
    [toViewController.view layoutIfNeeded];
    CGAffineTransform originalToTransform = toViewController.view.transform;
    CGAffineTransform originalFromTransform = fromViewController.view.transform;
    
    CGRect fromRect = [(CALImageViewController *)fromViewController transitionRectForTransitionContext:transitionContext];
    CGRect toRect = [(ViewController *)toViewController transitionRectForTransitionContext:transitionContext];
    CGAffineTransform toToFromTransform = CGAffineTransformFromRectToRect(toRect, fromRect);
    
    UIView *fromVCSnapshot = [[self class] snapshotViewFromView:fromViewController.view afterScreenUpdates:YES];
    UIView *toVCSnapshot = [[self class] snapshotViewFromView:toViewController.view afterScreenUpdates:YES];
    toVCSnapshot.transform = CGAffineTransformConcat(originalToTransform, toToFromTransform);
    [containerView addSubview:toVCSnapshot];
    [containerView addSubview:fromVCSnapshot];
    
    [toViewController beginAppearanceTransition:YES animated:YES];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         fromVCSnapshot.alpha = 0;
                         fromVCSnapshot.transform = CGAffineTransformConcat(originalFromTransform, CGAffineTransformInvert(toToFromTransform));
                         toVCSnapshot.transform = originalToTransform;
                     } completion:^(BOOL finished) {
                         [fromVCSnapshot removeFromSuperview];
                         [toVCSnapshot removeFromSuperview];
                         [containerView addSubview:toViewController.view];
                         [fromViewController.view removeFromSuperview];
                         [toViewController endAppearanceTransition];
                         [transitionContext completeTransition:YES];
                     }];
}

+ (UIView *)snapshotViewFromView:(UIView *)inView afterScreenUpdates:(BOOL)afterScreenUpdates {
    UIView *replicantView = [inView snapshotViewAfterScreenUpdates:afterScreenUpdates];
    replicantView.alpha = inView.alpha;
    replicantView.bounds = inView.bounds;
    replicantView.center = inView.center;
    replicantView.contentScaleFactor = inView.contentScaleFactor;
    replicantView.transform = inView.transform;
    return replicantView;
}

// http://stackoverflow.com/a/14764286/1621334 and Danny Zlobinsky
// does not consider rotation
CG_INLINE CGAffineTransform CGAffineTransformFromRectToRect(CGRect fromRect, CGRect toRect) {
    CGSize scale = CGSizeMake(toRect.size.width/fromRect.size.width, toRect.size.height/fromRect.size.height);
    CGPoint translation = CGPointMake(CGRectGetMidX(toRect) - CGRectGetMidX(fromRect), CGRectGetMidY(toRect) - CGRectGetMidY(fromRect));
    return CGAffineTransformMake(scale.width, 0, 0, scale.height, translation.x, translation.y);
}

@end
