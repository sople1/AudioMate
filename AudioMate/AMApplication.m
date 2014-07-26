//
//  AudioMateApplication.m
//  AudioMate
//
//  Created by Ruben Nine on 12/29/12.
//  Copyright (c) 2012 Ruben Nine. All rights reserved.
//

#import "AMApplication.h"

@implementation AMApplication

// Based on http://stackoverflow.com/questions/970707/cocoa-keyboard-shortcuts-in-dialog-without-an-edit-menu

- (void)sendEvent:(NSEvent *)event
{
    if ([event type] == NSKeyDown)
    {
        NSString *characters = [event charactersIgnoringModifiers];

        if (([event modifierFlags] & NSDeviceIndependentModifierFlagsMask) == NSCommandKeyMask)
        {
            if ([characters isEqualToString:@"x"])
            {
                if ([self sendAction:@selector(cut:)
                                  to:nil
                                from:self])
                {
                    return;
                }
            }
            else if ([characters isEqualToString:@"c"])
            {
                if ([self sendAction:@selector(copy:)
                                  to:nil
                                from:self])
                {
                    return;
                }
            }
            else if ([characters isEqualToString:@"v"])
            {
                if ([self sendAction:@selector(paste:)
                                  to:nil
                                from:self])
                {
                    return;
                }
            }
            else if ([characters isEqualToString:@"z"])
            {
                SEL selector = NSSelectorFromString(@"undo:");

                if ([self sendAction:selector
                                  to:nil
                                from:self])
                {
                    return;
                }
            }
            else if ([characters isEqualToString:@"a"])
            {
                if ([self sendAction:@selector(selectAll:)
                                  to:nil
                                from:self])
                {
                    return;
                }
            }
            else if ([characters isEqualToString:@"w"])
            {
                if ([self sendAction:@selector(performClose:)
                                  to:nil
                                from:self])
                {
                    return;
                }
            }
            else if ([characters isEqualToString:@"q"])
            {
                if ([self sendAction:@selector(terminate:)
                                  to:nil
                                from:self])
                {
                    return;
                }
            }
        }
        else if (([event modifierFlags] & NSDeviceIndependentModifierFlagsMask) == (NSCommandKeyMask | NSShiftKeyMask))
        {
            if ([characters isEqualToString:@"Z"])
            {
                SEL selector = NSSelectorFromString(@"redo:");

                if ([self sendAction:selector
                                  to:nil
                                from:self])
                {
                    return;
                }
            }
        }
    }

    [super sendEvent:event];
}

@end
