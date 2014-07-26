//
//  AMAudioDeviceActions.h
//  AudioMate
//
//  Created by Ruben Nine on 25/06/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMAudioDeviceActions : NSObject

@property (nonatomic, assign) BOOL setSampleRate;
@property (nonatomic, assign) BOOL setClockSource;
@property (nonatomic, assign) BOOL setVolume;
@property (nonatomic, retain) NSNumber *targetSampleRate;
@property (nonatomic, retain) NSString *targetClockSourceName;
@property (nonatomic, retain) NSNumber *targetVolume;

- (NSArray *)allProperties;

@end
