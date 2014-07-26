//
//  NSImage+BWTinting.m
//  AudioMate
//
//  Created by Ruben Nine on 10/07/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import "NSImage+BWTinting.h"

@implementation NSImage (BWTinting)

- (NSImage *)BWTintedImageWithColor:(NSColor *)tint
{
    NSRect imageBounds = NSMakeRect(0, 0, self.size.width, self.size.height);
    NSImage *copiedImage = [self copy];

    [copiedImage lockFocus];
    {
        [tint set];
        NSRectFillUsingOperation(imageBounds, NSCompositeSourceAtop);
    }
    [copiedImage unlockFocus];

    return copiedImage;
}

@end
