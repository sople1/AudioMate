//
//  Setting.h
//  AudioMate
//
//  Created by Ruben Nine on 12/21/12.
//  Copyright (c) 2012 Ruben Nine. All rights reserved.
//

#import "AMAudioDeviceActions.h"
#import "AMGeneralPreferences.h"
#import "AMNotificationsPreferences.h"
#import "AMDevicePreferences.h"

extern const NSString *kAMNoAudioDevice;

@interface AMPreferences : NSObject

@property (nonatomic, retain) AMGeneralPreferences *general;
@property (nonatomic, retain) AMNotificationsPreferences *notifications;
@property (nonatomic, retain) AMDevicePreferences *device;

+ (instancetype)sharedPreferences;

- (void)setDeviceActions:(AMAudioDeviceActions *)deviceActions
       forAudioDeviceUID:(NSString *)deviceUID;

- (AMAudioDeviceActions *)deviceActionsForAudioDeviceUID:(NSString *)deviceUID;

@end
