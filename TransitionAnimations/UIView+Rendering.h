//
//  UIView+Rendering.h
//  TransitionAnimations
//
//  Created by Logan Moseley on 3/19/15.
//  Copyright (c) 2015 CalamitySoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Rendering)

- (UIView *)snapshotViewAfterScreenUpdates:(BOOL)afterUpdates copyProperties:(BOOL)copyProperties;

@end
