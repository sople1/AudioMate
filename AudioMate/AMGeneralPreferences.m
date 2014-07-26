//
//  AMGeneralPreferences.m
//  AudioMate
//
//  Created by Ruben Nine on 12/07/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import "AMGeneralPreferences.h"

@implementation AMGeneralPreferences

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ {isFirstLaunch: %d, isPopupTransient: %d, shouldShowMasterVolumes: %d, shouldPlayFeedbackSound: %d, statusBarAppearance: %lu}",
            [super description],
            self.isFirstLaunch,
            self.isPopupTransient,
            self.shouldShowMasterVolumes,
            self.shouldPlayFeedbackSound,
            self.statusBarAppearance];
}

@end
