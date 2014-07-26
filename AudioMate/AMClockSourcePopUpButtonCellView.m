//
//  AMAudioDeviceClockSourceCellView.m
//  AudioMate
//
//  Created by Ruben Nine on 3/4/13.
//  Copyright (c) 2013 Ruben Nine. All rights reserved.
//

#import "AMClockSourcePopUpButtonCellView.h"
#import <AMCoreAudio/AMCoreAudio.h>

@implementation AMClockSourcePopUpButtonCellView

- (void)populateWithAudioDevice:(AMCoreAudioDevice *)audioDevice
{
    NSString *actualClockSourceName;
    NSArray *clockSources;

    actualClockSourceName = [audioDevice clockSourceForChannel:kAudioObjectPropertyElementMaster
                                                  andDirection:kAMCoreAudioDevicePlaybackDirection];

    if ([AMCoreAudioDefaultClockSourceName isEqualToString:actualClockSourceName])
    {
        self.supportedClockSourcesPopUpButton.toolTip = NSLocalizedString(@"Default clock source", nil);
    }
    else
    {
        self.supportedClockSourcesPopUpButton.toolTip = [NSString stringWithFormat:NSLocalizedString(@"%@ clock source", nil), actualClockSourceName];
    }

    clockSources = [audioDevice clockSourcesForChannel:kAudioObjectPropertyElementMaster
                                          andDirection:kAMCoreAudioDevicePlaybackDirection];

    self.supportedClockSourcesPopUpButton.enabled = clockSources.count > 0;
    [self.supportedClockSourcesPopUpButton.menu setAutoenablesItems:NO];

    if (clockSources.count > 0)
    {
        NSMenuItem *menuItem = [[self.supportedClockSourcesPopUpButton.menu itemAtIndex:0] copy];

        [self.supportedClockSourcesPopUpButton.menu removeAllItems];
        [self.supportedClockSourcesPopUpButton.menu addItem:menuItem];

        for (NSString *clockSourceName in clockSources)
        {
            menuItem = [NSMenuItem new];
            menuItem.title = clockSourceName;
            menuItem.target = self.target;
            menuItem.action = self.action;

            if (![clockSourceName isEqualToString:actualClockSourceName])
            {
                menuItem.representedObject = audioDevice;
            }
            else
            {
                menuItem.enabled = NO;
            }

            [self.supportedClockSourcesPopUpButton.menu addItem:menuItem];
        }
    }
}

@end
