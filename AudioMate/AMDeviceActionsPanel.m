//
//  AMDeviceActionsPanel.m
//  AudioMate
//
//  Created by Ruben Nine on 10/07/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import "AMDeviceActionsPanel.h"
#import <AMCoreAudio/AMCoreAudio.h>
#import <AMCoreAudio/AMCoreAudioDevice+Formatters.h>
#import <AMCoreAudio/AMCoreAudioDevice+PreferredDirections.h>
#import "AMAudioDeviceActions.h"
#import "AMPreferences.h"

@implementation AMDeviceActionsPanel

- (void)setAudioDevice:(AMCoreAudioDevice *)audioDevice
{
    _audioDevice = audioDevice;

    AMAudioDeviceActions *deviceActions;
    NSArray *nominalSampleRates;
    NSArray *clockSources;
    NSArray *channels;
    NSString *actualClockSourceName;
    AMCoreAudioDirection direction;
    BOOL canSetMasterVolume;
    BOOL canSetSampleRate;
    BOOL canSetClockSource;

    deviceActions = [[AMPreferences sharedPreferences] deviceActionsForAudioDeviceUID:audioDevice.deviceUID];

    direction = audioDevice.preferredDirectionForMasterVolume;
    channels = [audioDevice preferredStereoChannelsForDirection:direction];

    canSetMasterVolume = [audioDevice canSetMasterVolumeForDirection:direction];
    canSetSampleRate = (audioDevice.nominalSampleRates.count > 1);
    canSetClockSource = [audioDevice clockSourcesForChannel:kAudioObjectPropertyElementMaster
                                               andDirection:direction];

    if (canSetMasterVolume && !deviceActions.targetVolume)
    {
        deviceActions.targetVolume = @([audioDevice masterVolumeForDirection:direction]);
    }

    // Set title

    self.titleTextField.stringValue = [NSString stringWithFormat:NSLocalizedString(@"%@ Actions", nil), audioDevice.deviceName];

    // Set master volume

    self.setMasterVolumeCheckbox.enabled = canSetMasterVolume;
    self.setMasterVolumeCheckbox.tag = audioDevice.deviceID;
    self.setMasterVolumeCheckbox.state = deviceActions.setVolume;
    self.setMasterVolumeCheckbox.target = self;
    self.setMasterVolumeCheckbox.action = @selector(enableVolumeAction:);

    self.masterVolumeSlider.enabled = canSetMasterVolume && deviceActions.setVolume;
    self.masterVolumeSlider.tag = audioDevice.deviceID;
    self.masterVolumeSlider.target = self;
    self.masterVolumeSlider.action = @selector(setVolumeAction:);

    self.masterVolumeTextField.enabled = canSetMasterVolume && deviceActions.setVolume;
    self.masterVolumeTextField.tag = audioDevice.deviceID;
    self.masterVolumeTextField.target = self;
    self.masterVolumeTextField.action = @selector(setVolumeAction:);

    // Set a decimal style number formatter for our volume text field
    // so the decimal separator is displayed correctly in each locale.

    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];

    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.localizesFormat = YES;

    self.masterVolumeTextField.formatter = numberFormatter;

    self.masterVolumeSlider.minValue = 0.0;
    self.masterVolumeSlider.maxValue = 1.0;
    self.masterVolumeSlider.floatValue = canSetMasterVolume ? deviceActions.targetVolume.floatValue : 1.0;

    if (canSetMasterVolume && channels.count > 0)
    {
        Float32 channel;
        AMCoreAudioVolumeInfo volumeInfo;

        volumeInfo = [audioDevice volumeInfoForChannel:kAudioObjectPropertyElementMaster
                                          andDirection:direction];

        if (volumeInfo.canSetVolume)
        {
            channel = kAudioObjectPropertyElementMaster;
        }
        else
        {
            channel = ((NSNumber *)channels[0]).floatValue;
        }

        self.masterVolumeTextField.floatValue = [audioDevice scalarToDecibels:deviceActions.targetVolume.floatValue
                                                                   forChannel:channel
                                                                 andDirection:direction];
    }
    else
    {
        self.masterVolumeTextField.stringValue = NSLocalizedString(@"N/A", nil);
    }

    // Set sample rate

    self.setSampleRateCheckbox.enabled = canSetSampleRate;
    self.setSampleRateCheckbox.tag = audioDevice.deviceID;
    self.setSampleRateCheckbox.state = deviceActions.setSampleRate;
    self.setSampleRateCheckbox.target = self;
    self.setSampleRateCheckbox.action = @selector(enableSampleRateAction:);

    self.sampleRatePopUpButton.enabled = canSetSampleRate && deviceActions.setSampleRate;
    self.sampleRatePopUpButton.tag = audioDevice.deviceID;

    [self.sampleRatePopUpButton removeAllItems];

    nominalSampleRates = audioDevice.nominalSampleRates;

    if (nominalSampleRates.count == 0)
    {
        [self.sampleRatePopUpButton addItemWithTitle:NSLocalizedString(@"N/A", nil)];
        [self.sampleRatePopUpButton selectItemAtIndex:0];
        [self.sampleRatePopUpButton setEnabled:NO];
    }
    else
    {
        __block NSString *formattedSampleRate;

        [nominalSampleRates enumerateObjectsUsingBlock: ^(id entry, NSUInteger idx, BOOL *stop)
        {
            NSNumber *sampleRate;
            NSMenuItem *menuItem;

            sampleRate = entry;
            formattedSampleRate = [AMCoreAudioDevice formattedSampleRate:sampleRate.doubleValue
                                                          useShortFormat:NO];

            // Get the newly appended menu item

            menuItem = [NSMenuItem new];
            menuItem.title = formattedSampleRate;
            menuItem.representedObject = sampleRate;
            menuItem.tag = audioDevice.deviceID;
            menuItem.target = self;
            menuItem.action = @selector(setSampleRateAction:);

            [self.sampleRatePopUpButton.menu addItem:menuItem];
        }];

        if (deviceActions.targetSampleRate)
        {
            formattedSampleRate = [AMCoreAudioDevice formattedSampleRate:deviceActions.targetSampleRate.doubleValue
                                                          useShortFormat:NO];
        }
        else
        {
            formattedSampleRate = [AMCoreAudioDevice formattedSampleRate:audioDevice.actualSampleRate
                                                          useShortFormat:NO];
        }

        [self.sampleRatePopUpButton selectItemWithTitle:formattedSampleRate];
    }


    // Set clock source

    self.setClockSourceCheckbox.enabled = canSetClockSource;
    self.setClockSourceCheckbox.tag = audioDevice.deviceID;
    self.setClockSourceCheckbox.state = deviceActions.setClockSource;
    self.setClockSourceCheckbox.target = self;
    self.setClockSourceCheckbox.action = @selector(enableClockSourceAction:);

    self.clockSourcePopUpButton.tag = audioDevice.deviceID;

    actualClockSourceName = [audioDevice clockSourceForChannel:kAudioObjectPropertyElementMaster
                                                  andDirection:direction];

    clockSources = [audioDevice clockSourcesForChannel:kAudioObjectPropertyElementMaster
                                          andDirection:direction];

    self.clockSourcePopUpButton.enabled = canSetClockSource && deviceActions.setClockSource && (clockSources.count > 0);
    [self.clockSourcePopUpButton.menu setAutoenablesItems:NO];
    [self.clockSourcePopUpButton.menu removeAllItems];

    if (clockSources.count == 0)
    {
        [self.clockSourcePopUpButton addItemWithTitle:NSLocalizedString(@"Default", nil)];
        [self.clockSourcePopUpButton selectItemAtIndex:0];
    }
    else
    {
        NSString *selectedClockSourceName;
        NSMenuItem *menuItem;

        for (NSString *clockSourceName in clockSources)
        {
            menuItem = [NSMenuItem new];
            menuItem.title = clockSourceName;
            menuItem.representedObject = clockSourceName;
            menuItem.tag = audioDevice.deviceID;
            menuItem.target = self;
            menuItem.action = @selector(setClockSourceAction:);

            [self.clockSourcePopUpButton.menu addItem:menuItem];
        }

        selectedClockSourceName = deviceActions.targetClockSourceName ? deviceActions.targetClockSourceName : actualClockSourceName;

        [self.clockSourcePopUpButton selectItemWithTitle:selectedClockSourceName];
    }
}

#pragma mark - Actions

- (IBAction)enableVolumeAction:(id)sender
{
    AudioObjectID audioObjectID = (AudioObjectID)[sender tag];
    AMCoreAudioDevice *audioDevice = [AMCoreAudioDevice deviceWithID:audioObjectID];
    AMAudioDeviceActions *deviceActions = [[AMPreferences sharedPreferences] deviceActionsForAudioDeviceUID:audioDevice.deviceUID];

    deviceActions.setVolume = [sender state];
    deviceActions.targetVolume = @(self.masterVolumeSlider.floatValue);

    [[AMPreferences sharedPreferences] setDeviceActions:deviceActions
                                      forAudioDeviceUID:audioDevice.deviceUID];

    self.masterVolumeSlider.enabled = deviceActions.setVolume;
    self.masterVolumeTextField.enabled = deviceActions.setVolume;

    [self.sheetDelegate deviceActionsChanged:self];
}

- (IBAction)enableSampleRateAction:(id)sender
{
    AMCoreAudioDevice *audioDevice;
    AudioObjectID audioObjectID;
    AMAudioDeviceActions *deviceActions;

    audioObjectID = (AudioObjectID)[sender tag];
    audioDevice = [AMCoreAudioDevice deviceWithID:audioObjectID];

    deviceActions = [[AMPreferences sharedPreferences] deviceActionsForAudioDeviceUID:audioDevice.deviceUID];

    deviceActions.setSampleRate = [sender state];
    deviceActions.targetSampleRate = self.sampleRatePopUpButton.selectedItem.representedObject;

    [[AMPreferences sharedPreferences] setDeviceActions:deviceActions
                                      forAudioDeviceUID:audioDevice.deviceUID];

    [self.sampleRatePopUpButton setEnabled:[sender state]];

    [self.sheetDelegate deviceActionsChanged:self];
}

- (IBAction)enableClockSourceAction:(id)sender
{
    AMCoreAudioDevice *audioDevice;
    AudioObjectID audioObjectID;
    AMAudioDeviceActions *deviceActions;

    audioObjectID = (AudioObjectID)[sender tag];
    audioDevice = [AMCoreAudioDevice deviceWithID:audioObjectID];
    deviceActions = [[AMPreferences sharedPreferences] deviceActionsForAudioDeviceUID:audioDevice.deviceUID];

    deviceActions.setClockSource = [sender state];
    deviceActions.targetClockSourceName = self.clockSourcePopUpButton.selectedItem.representedObject;

    [[AMPreferences sharedPreferences] setDeviceActions:deviceActions
                                      forAudioDeviceUID:audioDevice.deviceUID];

    [self.clockSourcePopUpButton setEnabled:[sender state]];
    [self.sheetDelegate deviceActionsChanged:self];
}

- (IBAction)setSampleRateAction:(id)sender
{
    AMCoreAudioDevice *audioDevice;
    AudioObjectID audioObjectID;
    AMAudioDeviceActions *deviceActions;

    audioObjectID = (AudioObjectID)[sender tag];
    audioDevice = [AMCoreAudioDevice deviceWithID:audioObjectID];
    deviceActions = [[AMPreferences sharedPreferences] deviceActionsForAudioDeviceUID:audioDevice.deviceUID];

    deviceActions.targetSampleRate = [sender representedObject];

    [[AMPreferences sharedPreferences] setDeviceActions:deviceActions
                                      forAudioDeviceUID:audioDevice.deviceUID];
}

- (IBAction)setClockSourceAction:(id)sender
{
    AMCoreAudioDevice *audioDevice;
    AudioObjectID audioObjectID;
    AMAudioDeviceActions *deviceActions;

    audioObjectID = (AudioObjectID)[sender tag];
    audioDevice = [AMCoreAudioDevice deviceWithID:audioObjectID];
    deviceActions = [[AMPreferences sharedPreferences] deviceActionsForAudioDeviceUID:audioDevice.deviceUID];

    deviceActions.targetClockSourceName = [sender representedObject];

    [[AMPreferences sharedPreferences] setDeviceActions:deviceActions
                                      forAudioDeviceUID:audioDevice.deviceUID];
}

- (IBAction)setVolumeAction:(id)sender
{
    AMCoreAudioDirection direction;
    AMCoreAudioDevice *audioDevice;
    AudioObjectID audioObjectID;
    AMAudioDeviceActions *deviceActions;
    NSNumber *targetVolume;
    NSArray *channels;

    audioObjectID = (AudioObjectID)[sender tag];
    audioDevice = [AMCoreAudioDevice deviceWithID:audioObjectID];
    deviceActions = [[AMPreferences sharedPreferences] deviceActionsForAudioDeviceUID:audioDevice.deviceUID];
    direction = audioDevice.preferredDirectionForMasterVolume;
    channels = [audioDevice preferredStereoChannelsForDirection:direction];

    if ([sender isKindOfClass:[NSTextField class]])
    {
        Float32 volumeInDecibels;
        Float32 scalarVolume;

        scalarVolume = 0.0;
        volumeInDecibels = [sender floatValue];

        if (channels && (channels.count > 0))
        {
            Float32 channel;

            AMCoreAudioVolumeInfo volumeInfo;

            volumeInfo = [audioDevice volumeInfoForChannel:kAudioObjectPropertyElementMaster
                                              andDirection:direction];

            if (volumeInfo.canSetVolume)
            {
                channel = kAudioObjectPropertyElementMaster;
            }
            else
            {
                channel = ((NSNumber *)channels[0]).floatValue;
            }

            scalarVolume = [audioDevice decibelsToScalar:volumeInDecibels
                                              forChannel:channel
                                            andDirection:direction];
            // Corrected decibel value

            volumeInDecibels = [audioDevice scalarToDecibels:scalarVolume
                                                  forChannel:channel
                                                andDirection:direction];
        }

        targetVolume = @(scalarVolume);

        self.masterVolumeSlider.floatValue = scalarVolume;
        self.masterVolumeTextField.floatValue = volumeInDecibels;
    }
    else if ([sender isKindOfClass:[NSSlider class]])
    {
        Float32 volumeInDecibels;
        Float32 scalarVolume;

        scalarVolume = [sender floatValue];
        volumeInDecibels = -INFINITY;

        if (channels && (channels.count > 0))
        {
            Float32 channel;

            AMCoreAudioVolumeInfo volumeInfo;

            volumeInfo = [audioDevice volumeInfoForChannel:kAudioObjectPropertyElementMaster
                                              andDirection:direction];

            if (volumeInfo.canSetVolume)
            {
                channel = kAudioObjectPropertyElementMaster;
            }
            else
            {
                channel = [channels[0] floatValue];
            }

            volumeInDecibels = [audioDevice scalarToDecibels:scalarVolume
                                                  forChannel:channel
                                                andDirection:direction];
        }

        targetVolume = @([sender floatValue]);

        self.masterVolumeTextField.floatValue = volumeInDecibels;
    }
    else
    {
        return;
    }

    deviceActions.targetVolume = targetVolume;

    [[AMPreferences sharedPreferences] setDeviceActions:deviceActions
                                      forAudioDeviceUID:audioDevice.deviceUID];
}

@end
