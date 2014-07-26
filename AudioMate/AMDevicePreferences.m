//
//  AMDevicePreferences.m
//  AudioMate
//
//  Created by Ruben Nine on 12/07/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import "AMDevicePreferences.h"

@implementation AMDevicePreferences

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ {actions: %@, featuredDeviceName: %@, featuredDeviceUID: %@, deviceInformationToShow: %lu}",
            [super description],
            self.actions,
            self.featuredDeviceName,
            self.featuredDeviceUID,
            self.deviceInformationToShow
    ];
}

@end
