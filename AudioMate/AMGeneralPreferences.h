//
//  AMGeneralPreferences.h
//  AudioMate
//
//  Created by Ruben Nine on 12/07/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger
{
    AMBlueStatusBarAppearance,
    AMGraphiteStatusBarAppearance,
    AMSystemStatusBarAppearance
} AMStatusBarAppearance;

@interface AMGeneralPreferences : NSObject

@property (nonatomic, assign) BOOL isFirstLaunch;
@property (nonatomic, assign) BOOL isPopupTransient;
@property (nonatomic, assign) BOOL shouldShowMasterVolumes;
@property (nonatomic, assign) BOOL shouldPlayFeedbackSound;
@property (nonatomic, assign) AMStatusBarAppearance statusBarAppearance;

@end
