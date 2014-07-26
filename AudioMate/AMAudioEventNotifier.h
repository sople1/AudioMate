//
//  AudioNotifier.h
//  AudioMate
//
//  Created by Ruben Nine on 16/12/13.
//  Copyright (c) 2013 Ruben Nine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMCoreAudio/AMCoreAudioTypes.h>

@class AMCoreAudioDevice;

@interface AMAudioEventNotifier : NSObject

+ (AMAudioEventNotifier *)sharedInstance;

- (void)sampleRateChangeNotificationWithAudioDevice:(AMCoreAudioDevice *)audioDevice;

- (void)volumeChangeNotificationWithAudioDevice:(AMCoreAudioDevice *)audioDevice
                                   andDirection:(AMCoreAudioDirection)direction;

- (void)muteChangeNotificationWithAudioDevice:(AMCoreAudioDevice *)audioDevice
                                 andDirection:(AMCoreAudioDirection)direction;

- (void)clockSourceChangeNotificationWithAudioDevice:(AMCoreAudioDevice *)audioDevice
                                       channelNumber:(NSInteger)channelNumber
                                        andDirection:(AMCoreAudioDirection)direction;

- (void)deviceListChangeNotificationWithAddedDevices:(NSSet *)addedDevices
                                   andRemovedDevices:(NSSet *)removedDevices;

@end
