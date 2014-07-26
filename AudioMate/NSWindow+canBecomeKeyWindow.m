//
//  NSWindow+canBecomeKeyWindow.m
//  AudioMate
//
//  Created by Ruben Nine on 14/01/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import "NSWindow+canBecomeKeyWindow.h"
#import "AMAppDelegate.h"

@implementation NSWindow (canBecomeKeyWindow)

/**
   This is to fix a bug in 10.7 where a NSPopover with a text field
   cannot be edited if its parent window won't become key.

   The pragma statements disable the corresponding warning for overriding
   an already-implemented method.
 */

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (BOOL)canBecomeKeyWindow
{
    if (self.class == NSClassFromString(@"NSStatusBarWindow"))
    {
        NSPopover *popover = [(AMAppDelegate *)[NSApp delegate] popoverController].popover;

        if (popover && ![popover isShown])
        {
            return NO;
        }
    }

    return YES;
}

#pragma clang diagnostic pop

@end
