//
//  AMPreferencesPanel.h
//  AudioMate
//
//  Created by Ruben Nine on 10/07/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import "AMSheetPanel.h"

@protocol AMPreferencesPanelDelegate <NSObject>

- (void)deviceInformationToShowChanged:(id)sender;

@end

@interface AMPreferencesPanel : AMSheetPanel

@property (weak) IBOutlet NSPopUpButton *deviceInformationToShowPopupButton;
@property (weak) IBOutlet NSPopUpButton *statusBarAppearancePopupButton;
@property (weak) IBOutlet NSButton *displayVolumeNotificationsCheckbox;
@property (weak) IBOutlet NSButton *displayMuteNotificationsCheckbox;
@property (weak) IBOutlet NSButton *displaySampleRateNotificationsCheckbox;
@property (weak) IBOutlet NSButton *displayClockSourceNotificationsCheckbox;
@property (weak) IBOutlet NSButton *displayDeviceChangesNotificationsCheckbox;
@property (weak) IBOutlet NSButton *playFeedbackSoundCheckbox;
@property (weak) IBOutlet NSButton *popupIsTransientCheckbox;
@property (weak) IBOutlet id<AMPreferencesPanelDelegate> sheetDelegate;

@end
