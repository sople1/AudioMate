//
//  AMDevicePreferences.h
//  AudioMate
//
//  Created by Ruben Nine on 12/07/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger
{
    AMSampleRateAndMasterOutVolume,
    AMSampleRateAndMasterOutVolumePercent,
    AMSampleRateAndMasterOutGraphicVolume,
    AMSampleRateAndClockSource,
    AMSampleRateOnly
} AMDeviceInformationToShow;

@interface AMDevicePreferences : NSObject

@property (nonatomic, retain) NSDictionary *actions;
@property (nonatomic, retain) NSString *featuredDeviceName;
@property (nonatomic, retain) NSString *featuredDeviceUID;
@property (nonatomic, assign) AMDeviceInformationToShow deviceInformationToShow;

@end
