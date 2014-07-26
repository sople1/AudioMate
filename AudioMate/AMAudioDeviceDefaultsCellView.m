//
//  AMAudioDeviceDefaultsCellView.m
//  AudioMate
//
//  Created by Ruben Nine on 2/26/13.
//  Copyright (c) 2013 Ruben Nine. All rights reserved.
//

#import "AMAudioDeviceDefaultsCellView.h"
#import <AMCoreAudio/AMCoreAudio.h>

@implementation AMAudioDeviceDefaultsCellView

- (void)populateWithAudioDevice:(AMCoreAudioDevice *)audioDevice
{
    [self.defaultInputImageView setHidden:![audioDevice isEqualTo:[AMCoreAudioDevice defaultInputDevice]]];
    [self.defaultOutputImageView setHidden:![audioDevice isEqualTo:[AMCoreAudioDevice defaultOutputDevice]]];
    [self.defaultSystemOutputImageView setHidden:![audioDevice isEqualTo:[AMCoreAudioDevice systemOutputDevice]]];
}

@end
