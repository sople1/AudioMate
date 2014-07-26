//
//  AMNotificationsPreferences.h
//  AudioMate
//
//  Created by Ruben Nine on 12/07/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMNotificationsPreferences : NSObject

@property (nonatomic, assign) BOOL displayVolume;
@property (nonatomic, assign) BOOL displayMute;
@property (nonatomic, assign) BOOL displaySamplerate;
@property (nonatomic, assign) BOOL displayClockSource;
@property (nonatomic, assign) BOOL displayDeviceChanges;

@end
