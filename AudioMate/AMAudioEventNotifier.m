//
//  AudioNotifier.m
//  AudioMate
//
//  Created by Ruben Nine on 16/12/13.
//  Copyright (c) 2013 Ruben Nine. All rights reserved.
//

#import "AMAudioEventNotifier.h"
#import <Growl/Growl.h>
#import <AMCoreAudio/AMCoreAudio.h>
#import "AMCoreAudioDevice+Formatters.h"
#import "AMPreferences.h"
#import "LVDebounce.h"

@implementation AMAudioEventNotifier

+ (AMAudioEventNotifier *)sharedInstance
{
    static AMAudioEventNotifier *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [AMAudioEventNotifier new];
    });

    return sharedInstance;
}

- (void)sampleRateChangeNotificationWithAudioDevice:(AMCoreAudioDevice *)audioDevice
{
    NSString *description;

    description = [NSString stringWithFormat:NSLocalizedString(@"%@ sample rate changed to %@", nil),
                   audioDevice.deviceName,
                   [audioDevice actualSampleRateFormattedWithShortFormat:YES]];

    [self generateGrowlNotificationWithName:@"Sample Rate Changed"
                                   andTitle:NSLocalizedString(@"Sample Rate Changed", nil)
                             andDescription:description];
}

- (void)volumeChangeNotificationWithAudioDevice:(AMCoreAudioDevice *)audioDevice
                                   andDirection:(AMCoreAudioDirection)direction
{
    NSString *name;
    NSString *title;
    NSString *description;

    name = @"Volume Changed";
    title = NSLocalizedString(@"Volume Changed", nil);

    Float32 volumeInDecibels = [audioDevice masterVolumeInDecibelsForDirection:direction];
    NSString *formattedVolume = [AMCoreAudioDevice formattedVolumeInDecibels:volumeInDecibels];

    description = [NSString stringWithFormat:NSLocalizedString(@"%@ volume changed to %@", nil),
                   audioDevice.deviceName,
                   formattedVolume];

    [LVDebounce fireAfter:[self currentEventDelay]
                   target:self
                 selector:@selector(tryToGenerateDelayedNotification:)
                 userInfo:@{ @"name":name,
                             @"title":title,
                             @"description":description,
                             @"audioDevice":audioDevice }];
}

- (void)muteChangeNotificationWithAudioDevice:(AMCoreAudioDevice *)audioDevice
                                 andDirection:(AMCoreAudioDirection)direction
{
    NSString *name;
    NSString *title;
    NSString *description;

    if ([audioDevice isMasterVolumeMutedForDirection:direction])
    {
        name = @"Audio Muted";
        title = NSLocalizedString(@"Audio Muted", nil);
        description = [NSString stringWithFormat:NSLocalizedString(@"%@ audio was muted", nil),
                       audioDevice.deviceName];
    }
    else
    {
        name = @"Audio Unmuted";
        title = NSLocalizedString(@"Audio Unmuted", nil);
        description = [NSString stringWithFormat:NSLocalizedString(@"%@ audio was unmuted", nil),
                       audioDevice.deviceName];
    }

    NSDictionary *userInfo = @{
        @"name":name,
        @"title":title,
        @"description":description,
        @"audioDevice":audioDevice
    };

    [LVDebounce fireAfter:[self currentEventDelay]
                   target:self
                 selector:@selector(tryToGenerateDelayedNotification2:)
                 userInfo:userInfo];
}

- (void)clockSourceChangeNotificationWithAudioDevice:(AMCoreAudioDevice *)audioDevice
                                       channelNumber:(NSInteger)channelNumber
                                        andDirection:(AMCoreAudioDirection)direction
{
    NSString *clockSourceName;
    NSString *description;

    clockSourceName = [audioDevice clockSourceForChannel:(UInt32)channelNumber
                                            andDirection:direction];

    description = [NSString stringWithFormat:NSLocalizedString(@"%@ clock source changed to %@", nil),
                   audioDevice.deviceName,
                   clockSourceName];

    [self generateGrowlNotificationWithName:@"Clock Source Changed"
                                   andTitle:NSLocalizedString(@"Clock Source Changed", nil)
                             andDescription:description];
}

- (void)deviceListChangeNotificationWithAddedDevices:(NSSet *)addedDevices
                                   andRemovedDevices:(NSSet *)removedDevices
{
    for (AMCoreAudioDevice *audioDevice in addedDevices)
    {
        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"%@ appeared", nil),
                                 audioDevice.deviceName];

        [self generateGrowlNotificationWithName:@"Audio Device Appeared"
                                       andTitle:NSLocalizedString(@"Audio Device Appeared", nil)
                                 andDescription:description];
    }

    for (AMCoreAudioDevice *audioDevice in removedDevices)
    {
        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"%@ disappeared", nil),
                                 audioDevice.cachedDeviceName];

        [self generateGrowlNotificationWithName:@"Audio Device Disappeared"
                                       andTitle:NSLocalizedString(@"Audio Device Disappeared", nil)
                                 andDescription:description];
    }
}

#pragma mark - Private

- (NSTimeInterval)currentEventDelay
{
    NSEvent *event = [NSApplication sharedApplication].currentEvent;

    BOOL eventTriggeredInOurApp = event.type == NSLeftMouseDragged ||
                                  event.type == NSLeftMouseDown ||
                                  event.type == NSLeftMouseUp;

    return eventTriggeredInOurApp ? 0.05 : 1.00;
}

- (void)generateGrowlNotificationWithName:(NSString *)name
                                 andTitle:(NSString *)title
                           andDescription:(NSString *)description
{
    [GrowlApplicationBridge notifyWithTitle:title
                                description:description
                           notificationName:name
                                   iconData:nil
                                   priority:1
                                   isSticky:NO
                               clickContext:nil];
}

- (void)tryToGenerateDelayedNotification:(NSTimer *)timer
{
    NSString *name;
    NSString *title;
    NSString *description;

    name = [timer.userInfo objectForKey:@"name"];
    title = [timer.userInfo objectForKey:@"title"];
    description = [timer.userInfo objectForKey:@"description"];

    [self generateGrowlNotificationWithName:name
                                   andTitle:title
                             andDescription:description];
}

// This is merely a proxy for tryToGenerateDelayedNotification:
// The purpose of this proxy is to be able to use LVDebounce in cases
// where tryToGenerateDelayedNotification: is already being blocked by the debouncer
//
// In our particular case we debounce:
// 1. volume notifications using tryToGenerateDelayedNotification:
// 2. mute notifications using tryToGenerateDelayedNotification2:

- (void)tryToGenerateDelayedNotification2:(NSTimer *)timer
{
    [self tryToGenerateDelayedNotification:timer];
}

@end
