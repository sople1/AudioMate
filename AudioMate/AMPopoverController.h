//
//  AudioDeviceListPopOverController.h
//  AudioMate
//
//  Created by Ruben on 12/20/12.
//  Copyright (c) 2012 Ruben Nine. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AMCoreAudio/AMCoreAudio.h>
#import "AMDeviceActionsPanel.h"
#import "AMPreferencesPanel.h"

@protocol AMPopoverControllerDelegate <NSObject>

- (void)popoverDidClose:(id)sender;

@end

@interface AMPopoverController : NSViewController <NSPopoverDelegate,
                                                   NSTableViewDelegate,
                                                   NSTableViewDataSource,
                                                   AMDeviceActionsPanelDelegate,
                                                   AMPreferencesPanelDelegate>

@property (weak) IBOutlet NSTextField *buildNumberTextField;
@property (weak) IBOutlet NSPopover *popover;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSButton *launchAtLoginCheckbox;
@property (weak) IBOutlet NSPopUpButton *featuredAudioDevicePopupButton;
@property (weak) IBOutlet NSButton *checkForUpdatesButton;
@property (weak) IBOutlet NSButton *showMasterVolumesButton;
@property (weak) IBOutlet NSButton *displayPreferencesButton;
@property (assign) IBOutlet AMDeviceActionsPanel *deviceActionsSheet;
@property (assign) IBOutlet AMPreferencesPanel *preferencesSheet;
@property (weak) IBOutlet id <AMPopoverControllerDelegate> delegate;

@property (nonatomic, retain) NSOrderedSet *audioDevices;
@property (nonatomic, readonly) AudioObjectID audioDeviceSliderInMovement;

- (void)refreshFeaturedAudioDevicePopup;
- (void)refreshTableWith:(NSSet *)set;
- (void)refreshTableColumnWithIdentifier:(NSString *)identifier;

- (BOOL)updateTableColumnWithIdentifier:(NSString *)identifier
                       andAudioObjectID:(AudioObjectID)audioObjectID;

- (IBAction)togglePopup:(id)sender;

@end
