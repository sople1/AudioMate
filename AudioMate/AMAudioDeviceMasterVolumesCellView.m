//
//  AMAudioDeviceMasterVolumesCellView.m
//  AudioMate
//
//  Created by Ruben Nine on 8/1/13.
//  Copyright (c) 2013 Ruben Nine. All rights reserved.
//

#import "AMAudioDeviceMasterVolumesCellView.h"
#import <AMCoreAudio/AMCoreAudio.h>
#import <AMCoreAudio/AMCoreAudioDevice+Formatters.h>
#import <AMCoreAudio/AMCoreAudioDevice+PreferredDirections.h>

@implementation AMAudioDeviceMasterVolumesCellView

- (void)populateWithAudioDevice:(AMCoreAudioDevice *)audioDevice
{
    AMCoreAudioDirection direction = audioDevice.preferredDirectionForMasterVolume;

    self.masterVolumesSlider.minValue = 0.0;
    self.masterVolumesSlider.maxValue = 1.0;
    self.masterVolumesSlider.tag = audioDevice.deviceID;
    self.masterVolumesSlider.target = self;

    // NOTE: Objects in cell view are reused, so when rows are added/removed
    // we need to reset everything (i.e., the enabled state on the slider!!)

    if (direction == kAMCoreAudioDeviceInvalidDirection)
    {
        self.masterVolumesSlider.target = nil;
        self.masterVolumesSlider.action = nil;
        self.masterVolumesSlider.floatValue = 1.0;
        self.masterVolumesSlider.toolTip = nil;
        self.masterVolumesSlider.enabled = NO;
    }
    else
    {
        self.masterVolumesSlider.target = self.target;
        self.masterVolumesSlider.action = self.action;
        self.masterVolumesSlider.floatValue = [audioDevice masterVolumeForDirection:direction];
        self.masterVolumesSlider.toolTip = [AMCoreAudioDevice formattedVolumeInDecibels:[audioDevice masterVolumeInDecibelsForDirection:direction]];
        self.masterVolumesSlider.enabled = YES;
    }
}

@end
