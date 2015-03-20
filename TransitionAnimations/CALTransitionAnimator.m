//
//  CALTransitionAnimator.m
//  TransitionAnimations
//
//  Created by Logan Moseley on 3/18/15.
//  Copyright (c) 2015 CalamitySoft. All rights reserved.
//

#import "CALTransitionAnimator.h"
#import "UIView+Rendering.h"
#import "NYTTransitionZoomAnimationDataSource.h"

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
    
    // layouts setup, transforms saved
    
    UIView *fromVCSnapshot = [fromViewController.view snapshotViewAfterScreenUpdates:YES copyProperties:YES];
    UIView *toVCSnapshot = [toViewController.view snapshotViewAfterScreenUpdates:YES copyProperties:YES];
    CGRect fromRect = [[self class] transitionRectFromViewController:fromViewController transitionContext:transitionContext];
    CGRect toRect = [[self class] transitionRectFromViewController:toViewController transitionContext:transitionContext];
    CGAffineTransform fromToToTransform = CGAffineTransformFromRectInRectToRect(fromRect, fromVCSnapshot.bounds, toRect);
    CGAffineTransform toToFromTransform = CGAffineTransformFromRectInRectToRect(toRect, toVCSnapshot.bounds, fromRect);
    
    toVCSnapshot.alpha = 0;
    toVCSnapshot.transform = toToFromTransform; // CGAffineTransformInvert(fromToToTransform);
    [containerView addSubview:fromVCSnapshot];
    [containerView addSubview:toVCSnapshot];
    
    // snapshots setup and ready to animate
    
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
    
    // layouts setup, transforms saved
    
    UIView *fromVCSnapshot = [fromViewController.view snapshotViewAfterScreenUpdates:YES copyProperties:YES];
    UIView *toVCSnapshot = [toViewController.view snapshotViewAfterScreenUpdates:YES copyProperties:YES];
    CGRect fromRect = [[self class] transitionRectFromViewController:fromViewController transitionContext:transitionContext];
    CGRect toRect = [[self class] transitionRectFromViewController:toViewController transitionContext:transitionContext];
    CGAffineTransform fromToToTransform = CGAffineTransformFromRectInRectToRect(fromRect, fromVCSnapshot.bounds, toRect);
    CGAffineTransform toToFromTransform = CGAffineTransformFromRectInRectToRect(toRect, toVCSnapshot.bounds, fromRect);
    
    toVCSnapshot.transform = CGAffineTransformConcat(originalToTransform, toToFromTransform);
    [containerView addSubview:toVCSnapshot];
    [containerView addSubview:fromVCSnapshot];
    
    // snapshots setup and ready to animate
    
    [toViewController beginAppearanceTransition:YES animated:YES];
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         fromVCSnapshot.alpha = 0;
                         fromVCSnapshot.transform = CGAffineTransformConcat(originalFromTransform, fromToToTransform);
                         toVCSnapshot.transform = originalToTransform;
                     } completion:^(BOOL finished) {
                         [fromVCSnapshot removeFromSuperview];
                         [toVCSnapshot removeFromSuperview];
                         [fromViewController.view removeFromSuperview];
                         [containerView addSubview:toViewController.view];
                         [toViewController endAppearanceTransition];
                         [transitionContext completeTransition:YES];
                     }];
}

+ (CGRect)transitionRectFromViewController:(UIViewController *)viewController transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    if ([viewController respondsToSelector:@selector(transitionRectForTransitionContext:)]) {
        return [(id)viewController transitionRectForTransitionContext:transitionContext];
    }
    else {
        return viewController.view.frame;
    }
}

// http://stackoverflow.com/a/14764286/1621334 and Danny Zlobinsky
// does not consider rotation
CG_INLINE CGAffineTransform CGAffineTransformFromRectInRectToRect(CGRect fromRect, CGRect fromSupr, CGRect toRect) {
    CGSize scale = CGSizeMake(toRect.size.width/fromRect.size.width, toRect.size.height/fromRect.size.height);
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale.width, scale.height);
    
    CGPoint fromSuprCenter = CGPointMake(CGRectGetMidX(fromSupr), CGRectGetMidY(fromSupr));
    CGPoint fromRectOffsetFromSuperCenter = CGPointSubtractPoint(fromRect.origin, fromSuprCenter);
    CGPoint scaledFromRectOffset = CGPointMultiplyBySize(fromRectOffsetFromSuperCenter, scale);
    CGPoint scaledFromRectOrigin = CGPointAddPoint(fromSuprCenter, scaledFromRectOffset);
    CGSize scaledFromRectSize = CGSizeMultiplyBySize(fromRect.size, scale);
    CGRect scaledFromRect = (CGRect){.origin = scaledFromRectOrigin, .size = scaledFromRectSize};
    CGPoint translation = CGPointMake(CGRectGetMidX(toRect) - CGRectGetMidX(scaledFromRect), CGRectGetMidY(toRect) - CGRectGetMidY(scaledFromRect));
    CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(translation.x, translation.y);
    
    return CGAffineTransformConcat(scaleTransform, translationTransform);
}

CG_INLINE CGSize CGSizeMultiplyBySize(CGSize s1, CGSize s2) {
    CGSize s;
    s.width = s1.width * s2.width;
    s.height = s1.height * s2.height;
    return s;
}

CG_INLINE CGPoint CGPointMultiplyBySize(CGPoint pt, CGSize s) {
    CGPoint p;
    p.x = pt.x * s.width;
    p.y = pt.y * s.height;
    return p;
}

CG_INLINE CGPoint CGPointAddPoint(CGPoint p1, CGPoint p2) {
    CGPoint p;
    p.x = p1.x + p2.x;
    p.y = p1.y + p2.y;
    return p;
}

CG_INLINE CGPoint CGPointSubtractPoint(CGPoint p1, CGPoint p2) {
    CGPoint p;
    p.x = p1.x - p2.x;
    p.y = p1.y - p2.y;
    return p;
}

@end
