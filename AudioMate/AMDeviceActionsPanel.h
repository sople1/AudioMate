//
//  AMDeviceActionsPanel.h
//  AudioMate
//
//  Created by Ruben Nine on 10/07/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import "AMSheetPanel.h"

@protocol AMDeviceActionsPanelDelegate <NSObject>

- (void)deviceActionsChanged:(id)sender;

@end

@class AMCoreAudioDevice;

@interface AMDeviceActionsPanel : AMSheetPanel

@property (weak) IBOutlet NSTextField *titleTextField;
@property (weak) IBOutlet NSButton *setMasterVolumeCheckbox;
@property (weak) IBOutlet NSButton *setSampleRateCheckbox;
@property (weak) IBOutlet NSButton *setClockSourceCheckbox;
@property (weak) IBOutlet NSSlider *masterVolumeSlider;
@property (weak) IBOutlet NSTextField *masterVolumeTextField;
@property (weak) IBOutlet NSPopUpButton *sampleRatePopUpButton;
@property (weak) IBOutlet NSPopUpButton *clockSourcePopUpButton;
@property (assign) IBOutlet id<AMDeviceActionsPanelDelegate> sheetDelegate;

@property (nonatomic, retain) AMCoreAudioDevice *audioDevice;

@end
