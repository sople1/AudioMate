//
//  AMPreferencesPanel.m
//  AudioMate
//
//  Created by Ruben Nine on 10/07/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import "AMPreferencesPanel.h"
#import "AMPreferences.h"
#import "AMStatusBarView.h"

@implementation AMPreferencesPanel

- (void)awakeFromNib
{
    [super awakeFromNib];

    // Set the initial state for our preferences checkboxes

    [self.displayVolumeNotificationsCheckbox bind:@"value"
                                         toObject:[AMPreferences sharedPreferences].notifications
                                      withKeyPath:@"displayVolume"
                                          options:nil];

    [self.displayMuteNotificationsCheckbox bind:@"value"
                                       toObject:[AMPreferences sharedPreferences].notifications
                                    withKeyPath:@"displayMute"
                                        options:nil];

    [self.displaySampleRateNotificationsCheckbox bind:@"value"
                                             toObject:[AMPreferences sharedPreferences].notifications
                                          withKeyPath:@"displaySamplerate"
                                              options:nil];

    [self.displayClockSourceNotificationsCheckbox bind:@"value"
                                              toObject:[AMPreferences sharedPreferences].notifications
                                           withKeyPath:@"displayClockSource"
                                               options:nil];

    [self.displayDeviceChangesNotificationsCheckbox bind:@"value"
                                                toObject:[AMPreferences sharedPreferences].notifications
                                             withKeyPath:@"displayDeviceChanges"
                                                 options:nil];

    [self.playFeedbackSoundCheckbox bind:@"value"
                                toObject:[AMPreferences sharedPreferences].general
                             withKeyPath:@"shouldPlayFeedbackSound"
                                 options:nil];

    [self.popupIsTransientCheckbox bind:@"value"
                               toObject:[AMPreferences sharedPreferences].general
                            withKeyPath:@"isPopupTransient"
                                options:nil];

    // Reset device information items

    [self.deviceInformationToShowPopupButton removeAllItems];

    [self.deviceInformationToShowPopupButton addItemsWithTitles:@[NSLocalizedString(@"Sample Rate + Master Output Volume", nil),
                                                                  NSLocalizedString(@"Sample Rate + Master Output Volume Percentage", nil),
                                                                  NSLocalizedString(@"Sample Rate + Master Output Volume Graphic", nil),
                                                                  NSLocalizedString(@"Sample Rate + Clock Source", nil),
                                                                  NSLocalizedString(@"Sample Rate", nil)]];

    NSMenuItem *menuItem;
    menuItem = [self.deviceInformationToShowPopupButton itemAtIndex:0];
    menuItem.tag = AMSampleRateAndMasterOutVolume;
    menuItem.target = self;
    menuItem.action = @selector(updateDeviceInformationToShow:);

    menuItem = [self.deviceInformationToShowPopupButton itemAtIndex:1];
    menuItem.tag = AMSampleRateAndMasterOutVolumePercent;
    menuItem.target = self;
    menuItem.action = @selector(updateDeviceInformationToShow:);

    menuItem = [self.deviceInformationToShowPopupButton itemAtIndex:2];
    menuItem.tag = AMSampleRateAndMasterOutGraphicVolume;
    menuItem.target = self;
    menuItem.action = @selector(updateDeviceInformationToShow:);

    menuItem = [self.deviceInformationToShowPopupButton itemAtIndex:3];
    menuItem.tag = AMSampleRateAndClockSource;
    menuItem.target = self;
    menuItem.action = @selector(updateDeviceInformationToShow:);

    menuItem = [self.deviceInformationToShowPopupButton itemAtIndex:4];
    menuItem.tag = AMSampleRateOnly;
    menuItem.target = self;
    menuItem.action = @selector(updateDeviceInformationToShow:);

    [self.deviceInformationToShowPopupButton selectItemWithTag:[AMPreferences sharedPreferences].device.deviceInformationToShow];

    // Reset status bar appareance items

    [self.statusBarAppearancePopupButton removeAllItems];

    [self.statusBarAppearancePopupButton addItemsWithTitles:@[NSLocalizedString(@"Blue appearance", nil),
                                                              NSLocalizedString(@"Graphite appearance", nil),
                                                              NSLocalizedString(@"Honor system's appearance", nil)]];

    menuItem = [self.statusBarAppearancePopupButton itemAtIndex:0];
    menuItem.tag = AMBlueStatusBarAppearance;
    menuItem.target = self;
    menuItem.action = @selector(updateStatusBarAppearance:);
    menuItem.image = [NSImage imageNamed:@"aqua_blue"];

    menuItem = [self.statusBarAppearancePopupButton itemAtIndex:1];
    menuItem.tag = AMGraphiteStatusBarAppearance;
    menuItem.target = self;
    menuItem.action = @selector(updateStatusBarAppearance:);
    menuItem.image = [NSImage imageNamed:@"graphite"];

    menuItem = [self.statusBarAppearancePopupButton itemAtIndex:2];
    menuItem.tag = AMSystemStatusBarAppearance;
    menuItem.target = self;
    menuItem.action = @selector(updateStatusBarAppearance:);

    [self.statusBarAppearancePopupButton selectItemWithTag:[AMPreferences sharedPreferences].general.statusBarAppearance];
}

#pragma mark - Preferences Actions

- (IBAction)updateDeviceInformationToShow:(id)sender
{
    [AMPreferences sharedPreferences].device.deviceInformationToShow = [sender tag];
    [self.sheetDelegate deviceInformationToShowChanged:self];
}

- (IBAction)updateStatusBarAppearance:(id)sender
{
    [AMPreferences sharedPreferences].general.statusBarAppearance = [sender tag];
    [[AMStatusBarView sharedInstance] controlTintChanged:self];
}

@end
