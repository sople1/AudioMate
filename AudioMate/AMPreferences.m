//
//  Setting.m
//  AudioMate
//
//  Created by Ruben Nine on 12/21/12.
//  Copyright (c) 2012 Ruben Nine. All rights reserved.
//

#import "AMPreferences.h"

const NSString *kAMNoAudioDevice = @"~NoAudioDevice";

static NSString *kGeneral = @"General";
static NSString *kGeneral_isFirstLaunch = @"General.isFirstLaunch";
static NSString *kGeneral_isPopupTransient = @"General.isPopupTransient";
static NSString *kGeneral_shouldShowMasterVolumes = @"General.shouldShowMasterVolumes";
static NSString *kGeneral_shouldPlayFeedbackSound = @"General.shouldPlayFeedbackSound";
static NSString *kGeneral_statusBarAppearance = @"General.statusBarAppearance";

static NSString *kDevice = @"Device";
static NSString *kDevice_actions = @"Device.actions";
static NSString *kDevice_featuredDeviceName = @"Device.featuredDeviceName";
static NSString *kDevice_featuredDeviceUID = @"Device.featuredDeviceUID";
static NSString *kDevice_deviceInformationToShow = @"Device.deviceInformationToShow";

static NSString *kNotifications = @"Notifications";
static NSString *kNotifications_displayVolume = @"Notifications.displayVolume";
static NSString *kNotifications_displayMute = @"Notifications.displayMute";
static NSString *kNotifications_displaySamplerate = @"Notifications.displaySamplerate";
static NSString *kNotifications_displayClockSource = @"Notifications.displayClockSource";
static NSString *kNotifications_displayDeviceChanges = @"Notifications.displayDeviceChanges";

@interface AMPreferences ()

@property (nonatomic, retain) NSDictionary *propertyMapping;

@end

@implementation AMPreferences

+ (void)initialize
{
    NSDictionary *defaults = @{
        kGeneral_isFirstLaunch:@YES,
        kGeneral_isPopupTransient:@YES,
        kGeneral_shouldShowMasterVolumes:@NO,
        kGeneral_shouldPlayFeedbackSound:@YES,
        kGeneral_statusBarAppearance:@(AMSystemStatusBarAppearance),

        kDevice_actions:@{},
        kDevice_featuredDeviceName:@"",
        kDevice_featuredDeviceUID:@"",
        kDevice_deviceInformationToShow:@(AMSampleRateAndMasterOutGraphicVolume),

        kNotifications_displayVolume:@YES,
        kNotifications_displayMute:@YES,
        kNotifications_displaySamplerate:@YES,
        kNotifications_displayClockSource:@YES,
        kNotifications_displayDeviceChanges:@YES
    };

    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];

    // This seems to be necessary in OS X 10.7 for proper initialization

    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaults];
}

+ (instancetype)sharedPreferences
{
    static dispatch_once_t onceToken;
    static AMPreferences *AMSharedPreferences = nil;

    dispatch_once(&onceToken, ^{
        AMSharedPreferences = [[super allocWithZone:NULL] init];
        [AMSharedPreferences setup];
    });

    return AMSharedPreferences;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedPreferences];
}

#pragma mark - Accessors

- (AMGeneralPreferences *)general
{
    if (!_general)
    {
        _general = [AMGeneralPreferences new];
    }

    return _general;
}

- (AMNotificationsPreferences *)notifications
{
    if (!_notifications)
    {
        _notifications = [AMNotificationsPreferences new];
    }

    return _notifications;
}

- (AMDevicePreferences *)device
{
    if (!_device)
    {
        _device = [AMDevicePreferences new];
    }

    return _device;
}

#pragma mark - Private

- (void)setup
{
    // Retrieve user defaults and populate our objects

    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];

    // Populate General Preferences

    self.general.isFirstLaunch = [[standardUserDefaults objectForKey:kGeneral_isFirstLaunch] boolValue];
    self.general.isPopupTransient = [[standardUserDefaults objectForKey:kGeneral_isPopupTransient] boolValue];
    self.general.shouldShowMasterVolumes = [[standardUserDefaults objectForKey:kGeneral_shouldShowMasterVolumes] boolValue];
    self.general.shouldPlayFeedbackSound = [[standardUserDefaults objectForKey:kGeneral_shouldPlayFeedbackSound] boolValue];
    self.general.statusBarAppearance = [[standardUserDefaults objectForKey:kGeneral_statusBarAppearance] unsignedIntegerValue];

    // Populate Notifications Preferences

    self.notifications.displayVolume = [[standardUserDefaults objectForKey:kNotifications_displayVolume] boolValue];
    self.notifications.displayMute = [[standardUserDefaults objectForKey:kNotifications_displayMute] boolValue];
    self.notifications.displaySamplerate = [[standardUserDefaults objectForKey:kNotifications_displaySamplerate] boolValue];
    self.notifications.displayClockSource = [[standardUserDefaults objectForKey:kNotifications_displayClockSource] boolValue];
    self.notifications.displayDeviceChanges = [[standardUserDefaults objectForKey:kNotifications_displayDeviceChanges] boolValue];

    // Populate Device Preferences

    self.device.actions = [standardUserDefaults objectForKey:kDevice_actions];
    self.device.featuredDeviceName = [standardUserDefaults objectForKey:kDevice_featuredDeviceName];
    self.device.featuredDeviceUID = [standardUserDefaults objectForKey:kDevice_featuredDeviceUID];
    self.device.deviceInformationToShow = [[standardUserDefaults objectForKey:kDevice_deviceInformationToShow] unsignedIntegerValue];

    // Initialize property mapping dictionary for look-ups

    self.propertyMapping = @{
        kGeneral:@{
            NSStringFromSelector(@selector(isFirstLaunch)):kGeneral_isFirstLaunch,
            NSStringFromSelector(@selector(isPopupTransient)):kGeneral_isPopupTransient,
            NSStringFromSelector(@selector(shouldShowMasterVolumes)):kGeneral_shouldShowMasterVolumes,
            NSStringFromSelector(@selector(shouldPlayFeedbackSound)):kGeneral_shouldPlayFeedbackSound,
            NSStringFromSelector(@selector(statusBarAppearance)):kGeneral_statusBarAppearance
        },
        kNotifications:@{
            NSStringFromSelector(@selector(displayVolume)):kNotifications_displayVolume,
            NSStringFromSelector(@selector(displayMute)):kNotifications_displayMute,
            NSStringFromSelector(@selector(displaySamplerate)):kNotifications_displaySamplerate,
            NSStringFromSelector(@selector(displayClockSource)):kNotifications_displayClockSource,
            NSStringFromSelector(@selector(displayDeviceChanges)):kNotifications_displayDeviceChanges
        },
        kDevice:@{
            NSStringFromSelector(@selector(actions)):kDevice_actions,
            NSStringFromSelector(@selector(featuredDeviceName)):kDevice_featuredDeviceName,
            NSStringFromSelector(@selector(featuredDeviceUID)):kDevice_featuredDeviceUID,
            NSStringFromSelector(@selector(deviceInformationToShow)):kDevice_deviceInformationToShow
        }
    };

    // Register observers for auto user default updating and delegate notifications

    for (id key in self.propertyMapping[kGeneral])
    {
        [self.general addObserver:self
                       forKeyPath:key
                          options:NSKeyValueObservingOptionNew
                          context:nil];
    }

    for (id key in self.propertyMapping[kNotifications])
    {
        [self.notifications addObserver:self
                             forKeyPath:key
                                options:NSKeyValueObservingOptionNew
                                context:nil];
    }

    for (id key in self.propertyMapping[kDevice])
    {
        [self.device addObserver:self
                      forKeyPath:key
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    }
}

#pragma mark - Properties

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    QLog(@"object = %@, keypath = %@, change = %@",
         object,
         keyPath,
         change);

    NSString *mappingKey;

    if ([object isEqualTo:self.general])
    {
        mappingKey = kGeneral;
    }
    else if ([object isEqualTo:self.notifications])
    {
        mappingKey = kNotifications;
    }
    else if ([object isEqualTo:self.device])
    {
        mappingKey = kDevice;
    }

    if (mappingKey)
    {
        NSString *userDefaultKey = self.propertyMapping[mappingKey][keyPath];

        if (userDefaultKey)
        {
            [[NSUserDefaults standardUserDefaults] setObject:change[NSKeyValueChangeNewKey]
                                                      forKey:userDefaultKey];

            return;
        }
    }

    [super observeValueForKeyPath:keyPath
                         ofObject:object
                           change:change
                          context:context];
}

#pragma mark - Accessors

- (void)setDeviceActions:(AMAudioDeviceActions *)deviceActions
       forAudioDeviceUID:(NSString *)deviceUID
{
    NSMutableDictionary *allDeviceActions = [self.device.actions mutableCopy];

    if (!allDeviceActions)
    {
        allDeviceActions = [NSMutableDictionary new];
    }

    NSArray *allProperties = [deviceActions allProperties];
    NSMutableDictionary *deviceActionsDictionary = [NSMutableDictionary dictionaryWithCapacity:allProperties.count];

    for (id key in allProperties)
    {
        id value = [deviceActions valueForKey:key];

        if (value)
        {
            deviceActionsDictionary[key] = value;
        }
    }

    allDeviceActions[deviceUID] = [deviceActionsDictionary copy];
    deviceActionsDictionary = nil;

    self.device.actions = [allDeviceActions copy];
}

- (AMAudioDeviceActions *)deviceActionsForAudioDeviceUID:(NSString *)deviceUID
{
    NSDictionary *deviceActionsDictionary = self.device.actions[deviceUID];
    AMAudioDeviceActions *deviceActions = [AMAudioDeviceActions new];

    for (id key in deviceActionsDictionary.allKeys)
    {
        [deviceActions setValue:deviceActionsDictionary[key]
                         forKey:key];
    }

    return deviceActions;
}

@end
