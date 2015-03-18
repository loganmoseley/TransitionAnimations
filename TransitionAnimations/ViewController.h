//
//  ViewController.h
//  TransitionAnimations
//
//  Created by Logan Moseley on 3/18/15.
//  Copyright (c) 2015 CalamitySoft. All rights reserved.
//

@import UIKit;

@interface ViewController : UIViewController

- (CGRect)transitionRectForTransitionContext:(id <UIViewControllerContextTransitioning>)transitionContext;

@end

