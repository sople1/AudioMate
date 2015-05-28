//
//  NSTableView+Calculations.m
//  AudioMate
//
//  Created by Ruben on 5/28/15.
//  Copyright (c) 2015 Ruben Nine. All rights reserved.
//

#import "NSTableView+Calculations.h"

@implementation NSTableView (Calculations)

/*!
 Calculates the actual table content height
 */
- (CGFloat)contentHeight
{
    CGFloat actualHeight = 0;

    for (int i = 0; i < self.numberOfRows; i++)
    {
        // Note that this is for view-based tableviews

        NSView *v = [self viewAtColumn:0
                                   row:i
                       makeIfNecessary:YES];

        if (v)
        {
            actualHeight += v.frame.size.height;

            // take intercell padding into account

            actualHeight += self.intercellSpacing.height;
        }
    }

    return actualHeight;
}

@end
