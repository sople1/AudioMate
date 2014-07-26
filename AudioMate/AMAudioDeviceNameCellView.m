//
//  AMAudioDeviceNameCellView.m
//  AudioMate
//
//  Created by Ruben Nine on 2/26/13.
//  Copyright (c) 2013 Ruben Nine. All rights reserved.
//

#import "AMAudioDeviceNameCellView.h"
#import <AMCoreAudio/AMCoreAudio.h>
#import "AMCoreAudioDevice+Formatters.h"

@implementation AMAudioDeviceNameCellView

- (void)populateWithAudioDevice:(AMCoreAudioDevice *)audioDevice
{
    self.nameTextField.stringValue = audioDevice.deviceName;
    self.nameTextField.toolTip = [NSString stringWithFormat:NSLocalizedString(@"Channels layout: %@\nI/O latency: %@", nil),
                                  [audioDevice numberOfChannelsDescription],
                                  [audioDevice latencyDescription]];
    self.channelLayoutDescriptionTextField.stringValue = audioDevice.numberOfChannelsDescription;
}

@end
