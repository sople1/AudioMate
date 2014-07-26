//
//  AMAudioDeviceMasterVolumesExtrasCellView.m
//  AudioMate
//
//  Created by Ruben Nine on 8/1/13.
//  Copyright (c) 2013 Ruben Nine. All rights reserved.
//

#import "AMAudioDeviceMasterVolumesExtrasCellView.h"
#import <AMCoreAudio/AMCoreAudio.h>
#import <AMCoreAudio/AMCoreAudioDevice+PreferredDirections.h>

@implementation AMAudioDeviceMasterVolumesExtrasCellView

- (void)populateWithAudioDevice:(AMCoreAudioDevice *)audioDevice
{
    AMCoreAudioDirection direction = [audioDevice preferredDirectionForMasterVolume];

    self.masterVolumeMuteButton.tag = audioDevice.deviceID;

    // NOTE: Objects in cell view are reused, so when rows are added/removed
    // we need to reset everything (i.e., the isEnabled state on the slider!!)

    if (direction == kAMCoreAudioDeviceInvalidDirection ||
        ![audioDevice canMuteMasterVolumeForDirection:direction])
    {
        self.masterVolumeMuteButton.target = nil;
        self.masterVolumeMuteButton.action = nil;
        self.masterVolumeMuteButton.state = NSOffState;
        self.masterVolumeMuteButton.toolTip = nil;
        self.masterVolumeMuteButton.enabled = NO;
    }
    else
    {
        self.masterVolumeMuteButton.target = self.target;
        self.masterVolumeMuteButton.action = self.action;
        self.masterVolumeMuteButton.state = [audioDevice isMasterVolumeMutedForDirection:direction];
        self.masterVolumeMuteButton.toolTip = self.masterVolumeMuteButton.state ? NSLocalizedString(@"Muted", nil) : NSLocalizedString(@"Unmuted", nil);
        self.masterVolumeMuteButton.enabled = YES;
    }
}

@end
