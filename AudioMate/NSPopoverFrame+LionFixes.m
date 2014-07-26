//
//  NSPopoverFrame+fixes.m
//  AudioMate
//
//  Created by Ruben Nine on 14/01/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import "NSPopoverFrame+LionFixes.h"

@implementation NSPopoverFrame (LionFixes)

- (struct CGRect)titlebarRect
{
    return CGRectMake(self.anchorSize.height,
                      self.anchorSize.height,
                      self.frame.size.width - self.anchorSize.width,
                      self.anchorSize.height);
}

@end
