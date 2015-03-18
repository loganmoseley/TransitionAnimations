//
//  CALTransitionController.m
//  TransitionAnimations
//
//  Created by Logan Moseley on 3/18/15.
//  Copyright (c) 2015 CalamitySoft. All rights reserved.
//

#import "CALTransitionController.h"
#import "CALTransitionAnimator.h"
#import "ViewController.h"
#import "CALImageViewController.h"

@implementation CALTransitionController

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(ViewController *)fromVC
                                                  toViewController:(CALImageViewController *)toVC
{
    CALTransitionAnimator *animator = [CALTransitionAnimator new];
    
    switch (operation) {
        case UINavigationControllerOperationPush:
            animator.isDismissing = NO;
            break;
        case UINavigationControllerOperationNone:
        case UINavigationControllerOperationPop:
            animator.isDismissing = YES;
            break;
    }
    
    return animator;
}

@end
