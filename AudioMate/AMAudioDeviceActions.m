//
//  AMAudioDeviceActions.m
//  AudioMate
//
//  Created by Ruben Nine on 25/06/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import "AMAudioDeviceActions.h"

@implementation AMAudioDeviceActions

- (NSString *)description
{
    return [NSString stringWithFormat:@"Enable Sample Rate: %d, Enable Clock Source: %d, Enable Volume: %d, SampleRate: %@, ClockSourceName: %@, Volume: %@",
            self.setSampleRate,
            self.setClockSource,
            self.setVolume,
            self.targetSampleRate,
            self.targetClockSourceName,
            self.targetVolume];
}

- (NSArray *)allProperties
{
    return @[
        NSStringFromSelector(@selector(setSampleRate)),
        NSStringFromSelector(@selector(setClockSource)),
        NSStringFromSelector(@selector(setVolume)),
        NSStringFromSelector(@selector(targetSampleRate)),
        NSStringFromSelector(@selector(targetClockSourceName)),
        NSStringFromSelector(@selector(targetVolume))
    ];
}

@end
