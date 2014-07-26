//
//  AMNotificationsPreferences.m
//  AudioMate
//
//  Created by Ruben Nine on 12/07/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import "AMNotificationsPreferences.h"

@implementation AMNotificationsPreferences

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ {displayVolume: %d, displayMute: %d, displaySamplerate: %d, displayClockSource: %d, displayDeviceChanges: %d}",
            [super description],
            self.displayVolume,
            self.displayMute,
            self.displaySamplerate,
            self.displayClockSource,
            self.displayDeviceChanges
    ];
}

@end
