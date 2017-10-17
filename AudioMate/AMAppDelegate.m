//
//  AppDelegate.m
//  AudioMate
//
//  Created by Ruben Nine on 12/2/12.
//  Copyright (c) 2012 Ruben Nine. All rights reserved.
//

#import "AMAppDelegate.h"

#ifndef APPSTORE
#import "PFMoveApplication.h"
#endif

#import <AMCoreAudio/AMCoreAudio.h>
#import <AMCoreAudio/AMCoreAudioDevice+PreferredDirections.h>
#import "AMPreferences.h"
#import "AMAudioDeviceActions.h"
#import "AMAudioEventNotifier.h"
#import "AMStatusBarView.h"

@interface AMAppDelegate () <AMCoreAudioManagerDelegate, NSUserNotificationCenterDelegate>

@property (nonatomic, strong) AMCoreAudioManager *audioManager;
@property (nonatomic, strong) NSRunningApplication *previousActiveApplication;

@end

@implementation AMAppDelegate

#pragma mark - Access Methods

- (AMCoreAudioManager *)audioManager
{
    if (!_audioManager)
    {
        _audioManager = [AMCoreAudioManager sharedManager];
    }

    return _audioManager;
}

#pragma mark - AMCoreAudioManagerDelegate Methods

- (void)hardwareDeviceListChangedWithAddedDevices:(NSSet *)addedDevices
                                andRemovedDevices:(NSSet *)removedDevices;
{
    // Generate system notification

    if ([AMPreferences sharedPreferences].notifications.displayDeviceChanges)
    {
        [[AMAudioEventNotifier sharedInstance] deviceListChangeNotificationWithAddedDevices:addedDevices
                                                                          andRemovedDevices:removedDevices];
    }

    [self runDeviceActionsOnDevices:addedDevices];

    dispatch_async(dispatch_get_main_queue(), ^{
      [self updatePopoverContent];
    });
}

- (void)hardwareDefaultInputDeviceChangedTo:(AMCoreAudioDevice *)audioDevice
{
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.popoverController refreshTableColumnWithIdentifier:@"Defaults"];
    });
}

- (void)hardwareDefaultOutputDeviceChangedTo:(AMCoreAudioDevice *)audioDevice
{
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.popoverController refreshTableColumnWithIdentifier:@"Defaults"];
      [self.popoverController refreshFeaturedAudioDevicePopup];

      // Refresh the status bar if necessary

      [AMStatusBarView sharedInstance].audioDevice = audioDevice;
    });
}

- (void)hardwareDefaultSystemDeviceChangedTo:(AMCoreAudioDevice *)audioDevice
{
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.popoverController refreshTableColumnWithIdentifier:@"Defaults"];
    });
}

- (void)audioDeviceListDidChange:(AMCoreAudioDevice *)audioDevice
{
    dispatch_async(dispatch_get_main_queue(), ^{
      [self updatePopoverContent];
    });
}

- (void)audioDeviceNameDidChange:(AMCoreAudioDevice *)audioDevice
{
    dispatch_async(dispatch_get_main_queue(), ^{
      // We can not just update the AudioDeviceName column, because it may
      // cause rows to become unordered, so we refresh the entire table

      [self.popoverController refreshTableWith:self.audioManager.allKnownDevices];
    });
}

- (void)audioDeviceNominalSampleRateDidChange:(AMCoreAudioDevice *)audioDevice
{
    dispatch_async(dispatch_get_main_queue(), ^{
      // Let's update the existing menu item to display the updated sample rate

      [self.popoverController updateTableColumnWithIdentifier:@"SupportedSampleRates"
                                             andAudioObjectID:audioDevice.deviceID];

      // Refresh the status bar if necessary

      [[AMStatusBarView sharedInstance] setNeedsDisplay:YES];
    });

    // Generate system notification

    if ([AMPreferences sharedPreferences].notifications.displaySamplerate)
    {
        [[AMAudioEventNotifier sharedInstance] sampleRateChangeNotificationWithAudioDevice:audioDevice];
    }
}

- (void)audioDeviceClockSourceDidChange:(AMCoreAudioDevice *)audioDevice
                             forChannel:(UInt32)channel
                           andDirection:(AMCoreAudioDirection)direction
{
    dispatch_async(dispatch_get_main_queue(), ^{
      // Let's update the clock sources to display the updated clock sources

      [self.popoverController updateTableColumnWithIdentifier:@"ClockSource"
                                             andAudioObjectID:audioDevice.deviceID];

      // Refresh the status bar if necessary

      [[AMStatusBarView sharedInstance] setNeedsDisplay:YES];
    });

    // Generate system notification

    if ([AMPreferences sharedPreferences].notifications.displayClockSource)
    {
        [[AMAudioEventNotifier sharedInstance] clockSourceChangeNotificationWithAudioDevice:audioDevice
                                                                              channelNumber:channel
                                                                               andDirection:direction];
    }
}

- (void)audioDeviceVolumeDidChange:(AMCoreAudioDevice *)audioDevice
                        forChannel:(UInt32)channel
                      andDirection:(AMCoreAudioDirection)direction
{
    dispatch_async(dispatch_get_main_queue(), ^{
      // Do not refresh the table row if the user is moving the slider
      // There's some strange glitches happening when that happens and
      // it is blatantly redundant in any case

      if (self.popoverController.audioDeviceSliderInMovement != audioDevice.deviceID)
      {
          [self.popoverController updateTableColumnWithIdentifier:@"MasterVolumes"
                                                 andAudioObjectID:audioDevice.deviceID];
      }

      // Refresh the status bar if necessary

      [[AMStatusBarView sharedInstance] setNeedsDisplay:YES];
    });

    // Generate system notification

    if ([AMPreferences sharedPreferences].notifications.displayVolume)
    {
        [[AMAudioEventNotifier sharedInstance] volumeChangeNotificationWithAudioDevice:audioDevice
                                                                          andDirection:direction];
    }
}

- (void)audioDeviceMuteDidChange:(AMCoreAudioDevice *)audioDevice
                      forChannel:(UInt32)channel
                    andDirection:(AMCoreAudioDirection)direction
{
    // We only care about the master channel mute here
    // So we can safely ignore any other channels (1,2, etc.)

    if (channel != kAudioObjectPropertyElementMaster)
    {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
      [self.popoverController updateTableColumnWithIdentifier:@"MasterVolumesExtras"
                                             andAudioObjectID:audioDevice.deviceID];

      // Refresh the status bar if necessary

      [[AMStatusBarView sharedInstance] setNeedsDisplay:YES];
    });

    // Generate system notification

    if ([AMPreferences sharedPreferences].notifications.displayMute)
    {
        [[AMAudioEventNotifier sharedInstance] muteChangeNotificationWithAudioDevice:audioDevice
                                                                        andDirection:direction];
    }
}

- (void)audioDeviceIsAliveDidChange:(AMCoreAudioDevice *)audioDevice
{
    // NO-OP
}

#pragma mark - NSApplicationDelegate Methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
#ifndef DEBUG
#ifndef APPSTORE
    PFMoveToApplicationsFolderIfNecessary();
#endif
#endif

    // Set NSUserNotificationCenter delegate to self

    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];

    // Set CoreAudioManager delegate to self

    self.audioManager.delegate = self;

    // Setup custom status bar menu

    [AMStatusBarView sharedInstance].target = self.popoverController;
    [AMStatusBarView sharedInstance].action = @selector(togglePopup:);

    // Subscribe to some NSWorkspace notifications

    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector:@selector(saveActiveApplication:)
                                                               name:NSWorkspaceDidActivateApplicationNotification
                                                             object:nil];

    // Subscribe to application did deactivate notificaiton

    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector:@selector(saveOriginalActiveApplication:)
                                                               name:NSWorkspaceDidDeactivateApplicationNotification
                                                             object:nil];

    // On first launch, get the default output device and set it as the featured audio device

    if ([AMPreferences sharedPreferences].general.isFirstLaunch)
    {
        AMCoreAudioDevice *defaultOutputDevice = [AMCoreAudioDevice defaultOutputDevice];

        if (defaultOutputDevice)
        {
            [AMPreferences sharedPreferences].device.featuredDeviceUID = (NSString *)kAMNoAudioDevice;
        }

        [AMPreferences sharedPreferences].general.isFirstLaunch = NO;
    }

    // Update the popover content

    [self updatePopoverContent];

    // Run device actions on startup...

    [self runDeviceActionsOnDevices:self.audioManager.allKnownDevices];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    self.audioManager.delegate = nil;

    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - AudioDeviceListPopOverControllerDelegate Methods

- (void)popoverDidClose:(id)sender
{
    // Reactivate the previous active application

    if (![NSApp mainWindow] &&
        self.previousActiveApplication)
    {
        [self.previousActiveApplication activateWithOptions:NSApplicationActivateIgnoringOtherApps];
    }

    [AMStatusBarView sharedInstance].isHighlighted = NO;
}

#pragma mark - NSUserNotificationCenterDelegate Methods

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

#pragma mark - Private Methods

- (void)runDeviceActionsOnDevices:(NSSet *)devices
{
    AMCoreAudioDirection direction;

    for (AMCoreAudioDevice *audioDevice in devices)
    {
        AMAudioDeviceActions *deviceActions;

        direction = audioDevice.preferredDirectionForMasterVolume;
        deviceActions = [[AMPreferences sharedPreferences] deviceActionsForAudioDeviceUID:audioDevice.deviceUID];

        if (deviceActions)
        {
            BOOL wasAbleToChangeSampleRate = NO;

            if (deviceActions.setVolume &&
                deviceActions.targetVolume)
            {
                [audioDevice setMasterVolume:deviceActions.targetVolume.floatValue
                                forDirection:direction];

                DLog(@"Setting target volume of %@ to %@",
                     audioDevice,
                     deviceActions.targetVolume);
            }

            if (deviceActions.setSampleRate &&
                deviceActions.targetSampleRate)
            {
                wasAbleToChangeSampleRate = [audioDevice setNominalSampleRate:deviceActions.targetSampleRate.doubleValue];

                DLog(@"Setting target sample rate of %@ to %@. Result: %d",
                     audioDevice,
                     deviceActions.targetSampleRate,
                     wasAbleToChangeSampleRate);
            }

            if (deviceActions.setClockSource &&
                deviceActions.targetClockSourceName)
            {
                [audioDevice setClockSource:deviceActions.targetClockSourceName
                                 forChannel:kAudioObjectPropertyElementMaster
                               andDirection:direction];

                DLog(@"Setting target clock source of %@ to %@",
                     audioDevice,
                     deviceActions.targetClockSourceName);
            }

            // Sometimes the sample rate may need to be changed after the clock source is changed
            // So we try again after the clock source is changed

            if (!wasAbleToChangeSampleRate)
            {
                if (deviceActions.setSampleRate && deviceActions.targetSampleRate)
                {
                    wasAbleToChangeSampleRate = [audioDevice setNominalSampleRate:deviceActions.targetSampleRate.doubleValue];

                    DLog(@"Setting target sample rate of %@ to %@. Result: %d",
                         audioDevice,
                         deviceActions.targetSampleRate,
                         wasAbleToChangeSampleRate);
                }
            }
        }
    }
}

- (void)updatePopoverContent
{
    [self.popoverController refreshTableWith:self.audioManager.allKnownDevices];
    [self.popoverController refreshFeaturedAudioDevicePopup];
}

- (void)saveOriginalActiveApplication:(NSNotification *)notification
{
    // This method will be called exactly once when NSWorkspaceDidDeactivateApplicationNotification is fired
    // so we have the chance to capture the original active app when the app launched

    // Remove observer (we only want this method to fire once)

    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self
                                                                  name:NSWorkspaceDidDeactivateApplicationNotification
                                                                object:nil];

    // Update previous active application

    self.previousActiveApplication = notification.userInfo[NSWorkspaceApplicationKey];
}

- (void)saveActiveApplication:(NSNotification *)notification
{
    NSRunningApplication *activeApplication;

    // We want to ensure that saveOriginalActiveApplication: initializes previouslyActiveApplication
    // before saveActiveApplication: does, so we return until previouslyActiveApplication
    // is initialized by saveOriginalActiveApplication:

    if (!self.previousActiveApplication)
    {
        return;
    }

    activeApplication = notification.userInfo[NSWorkspaceApplicationKey];

    if (![NSRunningApplication currentApplication].isActive)
    {
        self.previousActiveApplication = activeApplication;

        if (self.popoverController.popover.behavior == NSPopoverBehaviorTransient &&
            self.popoverController.popover.isShown)
        {
            [self.popoverController.popover close];
        }
    }
}

@end
