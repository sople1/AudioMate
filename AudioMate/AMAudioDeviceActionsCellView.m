//
//  AMAudioDeviceActionsCellView.m
//  AudioMate
//
//  Created by Ruben Nine on 13/01/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import "AMAudioDeviceActionsCellView.h"
#import <AMCoreAudio/AMCoreAudio.h>
#import "AMPreferences.h"
#import "NSImage+BWTinting.h"

@implementation AMAudioDeviceActionsCellView

- (void)populateWithAudioDevice:(AMCoreAudioDevice *)audioDevice
{
    NSColor *tintColor = tintColor = [NSColor colorWithCalibratedRed:0.55
                                                               green:0.0
                                                                blue:0.55
                                                               alpha:1.0];

    self.actionsButton.tag = audioDevice.deviceID;
    self.actionsButton.toolTip = [NSString stringWithFormat:NSLocalizedString(@"%@ Actions", nil), audioDevice.deviceName];
    self.actionsButton.target = self.target;
    self.actionsButton.action = self.action;

    AMAudioDeviceActions *deviceActions = [[AMPreferences sharedPreferences] deviceActionsForAudioDeviceUID:audioDevice.deviceUID];

    if (deviceActions &&
        (deviceActions.setVolume ||
         deviceActions.setSampleRate ||
         deviceActions.setClockSource))
    {
        self.actionsButton.image = [[NSImage imageNamed:@"NSActionTemplate"] BWTintedImageWithColor:tintColor];

        [self.actionsButton.image setTemplate:NO];
    }
    else
    {
        self.actionsButton.image = [NSImage imageNamed:@"NSActionTemplate"];

        [self.actionsButton.image setTemplate:YES];
    }
}

@end
