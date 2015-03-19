//
//  UIView+Rendering.m
//  TransitionAnimations
//
//  Created by Logan Moseley on 3/19/15.
//  Copyright (c) 2015 CalamitySoft. All rights reserved.
//

#import "UIView+Rendering.h"

@implementation UIView (Rendering)

- (UIView *)snapshotViewAfterScreenUpdates:(BOOL)afterUpdates copyProperties:(BOOL)copyProperties {
    UIView *replicantView = [self snapshotViewAfterScreenUpdates:afterUpdates];
    if (copyProperties) {
        replicantView.alpha = self.alpha;
        replicantView.bounds = self.bounds;
        replicantView.center = self.center;
        replicantView.contentScaleFactor = self.contentScaleFactor;
        replicantView.transform = self.transform;
    }
    return replicantView;
}

@end
