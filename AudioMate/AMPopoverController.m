//
//  AudioDeviceListPopOverController.m
//  AudioMate
//
//  Created by Ruben on 12/20/12.
//  Copyright (c) 2012 Ruben Nine. All rights reserved.
//

#import "AMPopoverController.h"

#ifndef APPSTORE
#import <Sparkle/SUUpdater.h>
#endif

#import <AMCoreAudio/AMCoreAudioDevice+Formatters.h>
#import <AMCoreAudio/AMCoreAudioDevice+PreferredDirections.h>
#import "AMPreferences.h"
#import "StartAtLoginController.h"
#import "AMCellViews.h"
#import "AMStatusBarView.h"
#import "AMDeviceActionsPanel.h"
#import "AMPreferencesPanel.h"
#import "NSImage+BWTinting.h"
#import "NSTableView+ContextMenu.h"
#import "NSWindow+canBecomeKeyWindow.h"

typedef enum : NSInteger
{
    kDefaultOuputDevice = -2,
    kNoSelection = -1
} FeaturedAudioDeviceSelection;

typedef enum : NSUInteger
{
    TagFollowUsOnTwitter = 0,
    TagVisitOurWebsite = 1,
    TagSendUsYourFeedback = 2
} AMContextualInfoMenuTag;

/**
   AMPopoverController private interface.
 */
@interface AMPopoverController ()
{
    CGFloat _originalPopoverContentHeight;
    CGFloat _originalTableViewHeight;
}

@property (nonatomic, retain) StartAtLoginController *startAtLoginController;
@property (nonatomic, retain) NSDictionary *configDictionary;
@property (nonatomic, retain) NSSound *feedbackSound;

@end

/**
   AMPopoverController class implementation.
 */
@implementation AMPopoverController

- (void)awakeFromNib
{
#ifdef APPSTORE
    self.checkForUpdatesButton.hidden = YES;
#endif
    
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 101000
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9)
    {
        self.popover.appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
    }
#endif
    
    [self.showMasterVolumesButton bind:@"value"
                              toObject:[AMPreferences sharedPreferences].general
                           withKeyPath:@"shouldShowMasterVolumes"
                               options:nil];

    self.displayPreferencesButton.toolTip = NSLocalizedString(@"Show Preferences", nil);

    // Keep table view sorted...

    self.tableView.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"AudioDeviceName"
                                                                     ascending:YES
                                                                      selector:@selector(compare:)]];

    self.tableView.refusesFirstResponder = YES;

    // Set launch at login checkbox state

    [self.launchAtLoginCheckbox setState:[self.startAtLoginController startAtLogin]];

    self.startAtLoginController = nil;

    // Set build number in UI

    NSDictionary *infoDictionary = [NSBundle mainBundle].infoDictionary;
    NSString *versionNumber = infoDictionary[@"CFBundleShortVersionString"];

    self.buildNumberTextField.stringValue = [NSString stringWithFormat:@"v%@", versionNumber];
}

#pragma mark - Accessors

- (StartAtLoginController *)startAtLoginController
{
    if (!_startAtLoginController)
    {
        _startAtLoginController = [[StartAtLoginController alloc] initWithIdentifier:@"io.9labs.AudioMateLauncher"];
    }

    return _startAtLoginController;
}

- (NSOrderedSet *)audioDevices
{
    if (!_audioDevices)
    {
        _audioDevices = [NSOrderedSet new];
    }

    return _audioDevices;
}

- (NSDictionary *)configDictionary
{
    if (!_configDictionary)
    {
        NSURL *configURL = [[NSBundle mainBundle] URLForResource:@"AMConfig"
                                                   withExtension:@"plist"];

        _configDictionary = [NSDictionary dictionaryWithContentsOfURL:configURL];
    }

    return _configDictionary;
}

- (NSSound *)feedbackSound
{
    if (!_feedbackSound)
    {
        _feedbackSound = [NSSound soundNamed:@"Select"];
    }

    return _feedbackSound;
}

#pragma mark - Public Methods

- (void)refreshFeaturedAudioDevicePopup
{
    NSMenu *popupMenu = self.featuredAudioDevicePopupButton.menu;
    NSMenuItem *menuItem;

    // Empty popup menu

    [popupMenu removeAllItems];

    // Add "None" entry

    menuItem = [NSMenuItem new];

    menuItem.title = NSLocalizedString(@"None", nil);
    menuItem.tag = kNoSelection;

    [popupMenu addItem:menuItem];

    // Add one menu entry per audio device

    for (AMCoreAudioDevice *audioDevice in self.audioDevices)
    {
        menuItem = [NSMenuItem new];

        menuItem.representedObject = audioDevice;
        menuItem.tag = audioDevice.deviceID;

        // An aggregate / multi-output audio device may return a null deviceName
        // at a certain point while it is in a transitory state

        if (!audioDevice.deviceName)
        {
            continue;
        }

        if ([self.featuredAudioDevicePopupButton itemWithTitle:audioDevice.deviceName])
        {
            // If item by this title already exist, also display the deviceID

            menuItem.title = [NSString stringWithFormat:@"%@ (%d)", audioDevice.deviceName, audioDevice.deviceID];
        }
        else
        {
            menuItem.title = audioDevice.deviceName;
        }

        if ([audioDevice.deviceUID isEqualToString:[AMCoreAudioDevice defaultOutputDevice].deviceUID])
        {
            menuItem.image = [NSImage imageNamed:@"DefaultOutput"];
        }

        [popupMenu addItem:menuItem];
    }

    // Add separator "--"

    [popupMenu addItem:[NSMenuItem separatorItem]];

    // Add "Match system's default audio output device" entry

    menuItem = [NSMenuItem new];

    menuItem.title = NSLocalizedString(@"Match system's default audio output device", nil);
    menuItem.tag = kDefaultOuputDevice;

    [popupMenu addItem:menuItem];

    [self selectFeaturedAudioDevicePopupEntry];
    [self refreshStatusbar];
}

- (void)refreshTableWith:(NSSet *)set
{
    NSSortDescriptor *descriptor;
    NSWindow *popoverWindow;
    NSResponder *currentResponder;

    // Let's set self.audioDevices with a copy of our given array sorted by 'name'

    descriptor = [NSSortDescriptor sortDescriptorWithKey:@"deviceName"
                                               ascending:YES];

    self.audioDevices = [NSOrderedSet orderedSetWithArray:[set sortedArrayUsingDescriptors:@[descriptor]]];

    popoverWindow = self.popover.contentViewController.view.window;
    currentResponder = popoverWindow.firstResponder;

    dispatch_async(dispatch_get_main_queue(), ^{
        // Update tableView

        [self.tableView reloadData];

        [popoverWindow recalculateKeyViewLoop];
        [popoverWindow makeFirstResponder:currentResponder];

        // Recalculate popover bounds based on tableView's size

        if ([self.popover isShown])
        {
            [self recalculatePopoverContentSize];
        }
    });
}

- (void)refreshTableColumnWithIdentifier:(NSString *)identifier
{
    NSIndexSet *rowIndexSet;
    NSIndexSet *columnIndexSet;

    rowIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.tableView.numberOfRows)];
    columnIndexSet = [NSIndexSet indexSetWithIndex:[self.tableView columnWithIdentifier:identifier]];

    NSResponder *currentResponder;
    currentResponder = self.popover.contentViewController.view.window.firstResponder;

    [self.tableView reloadDataForRowIndexes:rowIndexSet
                              columnIndexes:columnIndexSet];

    [self.popover.contentViewController.view.window recalculateKeyViewLoop];
    [self.popover.contentViewController.view.window makeFirstResponder:currentResponder];
}

- (BOOL)updateTableColumnWithIdentifier:(NSString *)identifier
                       andAudioObjectID:(AudioObjectID)audioObjectID
{
    NSInteger row;
    NSInteger column;
    AMCoreAudioDevice *audioDevice;
    BOOL rowAndColumnFound;

    audioDevice = [AMCoreAudioDevice deviceWithID:audioObjectID];
    row = [self.audioDevices indexOfObject:audioDevice];
    column = [self.tableView columnWithIdentifier:identifier];

    rowAndColumnFound = ((row != NSNotFound) && (column != -1));

    if (rowAndColumnFound)
    {
        NSIndexSet *ris = [NSIndexSet indexSetWithIndex:row];
        NSIndexSet *cis = [NSIndexSet indexSetWithIndex:column];

        NSResponder *currentResponder;

        currentResponder = self.popover.contentViewController.view.window.firstResponder;

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadDataForRowIndexes:ris columnIndexes:cis];

            [self.popover.contentViewController.view.window recalculateKeyViewLoop];
            [self.popover.contentViewController.view.window makeFirstResponder:currentResponder];
        });
    }

    return rowAndColumnFound;
}

#pragma mark - NSTableViewDelegate Methods

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row
{
    NSString *identifier = tableColumn.identifier;

    if ([identifier isEqualToString:@"AudioDeviceName"] ||
        [identifier isEqualToString:@"Defaults"] ||
        [identifier isEqualToString:@"SupportedSampleRates"] ||
        [identifier isEqualToString:@"ClockSource"] ||
        [identifier isEqualToString:@"MasterVolumes"] ||
        [identifier isEqualToString:@"MasterVolumesExtras"] ||
        [identifier isEqualToString:@"Actions"])
    {
        AMCellView *cellView = [tableView makeViewWithIdentifier:identifier
                                                           owner:tableView];

        if (!cellView.target ||
            !cellView.action)
        {
            if ([cellView isKindOfClass:[AMAudioDeviceActionsCellView class]])
            {
                cellView.target = self;
                cellView.action = @selector(displayDeviceActionsSheet:);
            }
            else if ([cellView isKindOfClass:[AMSampleRatePopUpButtonCellView class]])
            {
                cellView.target = self;
                cellView.action = @selector(changeCurrentSampleRate:);
            }
            else if ([cellView isKindOfClass:[AMClockSourcePopUpButtonCellView class]])
            {
                cellView.target = self;
                cellView.action = @selector(changeClockSource:);
            }
            else if ([cellView isKindOfClass:[AMAudioDeviceMasterVolumesCellView class]])
            {
                cellView.target = self;
                cellView.action = @selector(masterVolumeSliderChanged:);
            }
            else if ([cellView isKindOfClass:[AMAudioDeviceMasterVolumesExtrasCellView class]])
            {
                cellView.target = self;
                cellView.action = @selector(masterVolumeMuteCheckBoxChanged:);
            }
            else if ([cellView isKindOfClass:[AMAudioDeviceActionsCellView class]])
            {
                cellView.target = self;
                cellView.action = @selector(displayDeviceActionsSheet:);
            }
        }

        [cellView populateWithAudioDevice:self.audioDevices[row]];

        return cellView;
    }
    else
    {
        NSAssert(NO, @"Unhandled table column identifier %@", identifier);
    }

    return nil;
}

#pragma mark - NSTableViewDataSource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.audioDevices.count;
}

#pragma mark - NSTableView ContextMenu Methods

- (NSMenu *)tableView:(NSTableView *)aTableView
          menuForRows:(NSIndexSet *)rows
{
    AMCoreAudioDevice *selectedAudioDevice;
    NSMenu *contextualMenu;
    NSMenuItem *soundInputMenuItem;
    NSMenuItem *soundOutputMenuItem;
    NSMenuItem *soundSystemOutputMenuItem;

    selectedAudioDevice = self.audioDevices[rows.firstIndex];
    contextualMenu = [NSMenu new];

    soundInputMenuItem = [NSMenuItem new];
    soundInputMenuItem.title = [NSString stringWithFormat:NSLocalizedString(@"Use %@ for sound input", nil), selectedAudioDevice.deviceName];
    soundInputMenuItem.image = [NSImage imageNamed:@"DefaultInput"];

    if ([AMCoreAudioDevice defaultInputDevice] != selectedAudioDevice &&
        [selectedAudioDevice channelsForDirection:kAMCoreAudioDeviceRecordDirection] > 0)
    {
        soundInputMenuItem.target = self;
        soundInputMenuItem.action = @selector(useDeviceForSoundInput:);
        soundInputMenuItem.representedObject = selectedAudioDevice;
    }

    soundOutputMenuItem = [NSMenuItem new];

    soundOutputMenuItem.title = [NSString stringWithFormat:NSLocalizedString(@"Use %@ for sound output", nil),
                                                           selectedAudioDevice.deviceName];

    soundOutputMenuItem.image = [NSImage imageNamed:@"DefaultOutput"];

    if ([AMCoreAudioDevice defaultOutputDevice] != selectedAudioDevice &&
        [selectedAudioDevice channelsForDirection:kAMCoreAudioDevicePlaybackDirection] > 0)
    {
        soundOutputMenuItem.target = self;
        soundOutputMenuItem.action = @selector(useDeviceForSoundOutput:);
        soundOutputMenuItem.representedObject = selectedAudioDevice;
    }

    soundSystemOutputMenuItem = [NSMenuItem new];

    soundSystemOutputMenuItem.title = [NSString stringWithFormat:NSLocalizedString(@"Play alerts and sound effects through %@", nil), selectedAudioDevice.deviceName];
    soundSystemOutputMenuItem.image = [NSImage imageNamed:@"SystemOutput"];

    if ([AMCoreAudioDevice systemOutputDevice] != selectedAudioDevice &&
        [selectedAudioDevice channelsForDirection:kAMCoreAudioDevicePlaybackDirection] > 0)
    {
        soundSystemOutputMenuItem.target = self;
        soundSystemOutputMenuItem.action = @selector(useDeviceForSystemOutput:);
        soundSystemOutputMenuItem.representedObject = selectedAudioDevice;
    }

    [contextualMenu addItem:soundInputMenuItem];
    [contextualMenu addItem:soundOutputMenuItem];
    [contextualMenu addItem:soundSystemOutputMenuItem];

    return contextualMenu;
}

#pragma mark - NSPopoverDelegate Methods

- (void)popoverWillShow:(NSNotification *)notification
{
    self.popover.behavior = [AMPreferences sharedPreferences].general.isPopupTransient ? NSPopoverBehaviorTransient : NSPopoverBehaviorSemitransient;

    [self toggleShowMasterVolumes:self.showMasterVolumesButton];
}

- (void)popoverDidShow:(NSNotification *)notification
{
    [self recalculatePopoverContentSize];
}

- (void)popoverDidClose:(NSNotification *)notification
{
    [self.deviceActionsSheet closeSheet:self];
    [self.preferencesSheet closeSheet:self];
    [self.delegate popoverDidClose:self];
}

#pragma mark - AMDeviceActionsPanelDelegate Methods

- (void)deviceActionsChanged:(id)sender
{
    AMDeviceActionsPanel *panel = sender;

    [self updateTableColumnWithIdentifier:@"Actions"
                         andAudioObjectID:panel.audioDevice.deviceID];
}

#pragma mark - AMPreferencesPanelDelegate Methods

- (void)deviceInformationToShowChanged:(id)sender
{
    [self refreshStatusbar];
}

#pragma mark - Actions

- (IBAction)togglePopup:(id)sender
{
    if (!self.popover.isShown)
    {
        [self.popover showRelativeToRect:[sender bounds]
                                  ofView:sender
                           preferredEdge:NSMaxYEdge];

        [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    }
    else
    {
        [self.popover close];
    }
}

- (IBAction)setLaunchAtLogin:(id)sender
{
    BOOL startAtLogin = ([sender state] == NSOnState);

    [self.startAtLoginController setStartAtLogin:startAtLogin];

    self.startAtLoginController = nil;
}

- (IBAction)checkForUpdates:(id)sender
{
    // Close the popover first

    [self.popover close];

    // And now check for updates
#ifndef APPSTORE
    [[SUUpdater sharedUpdater] checkForUpdates:self];
#endif
}

- (IBAction)openBrowserURL:(id)sender
{
    NSURL *URLToOpen;

    AMContextualInfoMenuTag tag = [sender tag];

    switch (tag)
    {
        case TagFollowUsOnTwitter:
            URLToOpen = [NSURL URLWithString:self.configDictionary[@"URLs"][@"TwitterURL"]];
            break;

        case TagSendUsYourFeedback:
            URLToOpen = [NSURL URLWithString:self.configDictionary[@"URLs"][@"ContactURL"]];
            break;

        case TagVisitOurWebsite:
            URLToOpen = [NSURL URLWithString:self.configDictionary[@"URLs"][@"WebsiteURL"]];
            break;

        default:
            break;
    }

    if (URLToOpen)
    {
        // Close the popover first

        [self.popover close];

        [[NSWorkspace sharedWorkspace] openURL:URLToOpen];
    }
}

- (IBAction)masterVolumeSliderChanged:(id)sender
{
    AudioObjectID audioObjectID = (AudioObjectID)[sender tag];
    AMCoreAudioDevice *audioDevice = [AMCoreAudioDevice deviceWithID:audioObjectID];

    _audioDeviceSliderInMovement = audioObjectID;

    [audioDevice setMasterVolume:[sender floatValue]
                    forDirection:audioDevice.preferredDirectionForMasterVolume];

    // Debounced call to masterVolumeSliderFinishedMoving:

    SEL sel = @selector(masterVolumeSliderFinishedMoving:);

    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:sel
                                               object:sender];

    [self performSelector:sel
               withObject:sender
               afterDelay:0.0];
}

- (void)masterVolumeSliderFinishedMoving:(id)sender
{
    NSSlider *slider = sender;
    AudioObjectID audioObjectID = (AudioObjectID)slider.tag;
    AMCoreAudioDevice *audioDevice = [AMCoreAudioDevice deviceWithID:audioObjectID];
    AMCoreAudioDirection direction = audioDevice.preferredDirectionForMasterVolume;
    Float32 masterVolumeInDecibels = [audioDevice masterVolumeInDecibelsForDirection:direction];

    // Let's synchronize the slider's value and tooltip
    // with the actual values from the audio device

    slider.floatValue = [audioDevice masterVolumeForDirection:direction];
    slider.toolTip = [AMCoreAudioDevice formattedVolumeInDecibels:masterVolumeInDecibels];

    if (direction == kAMCoreAudioDevicePlaybackDirection &&
        [AMPreferences sharedPreferences].general.shouldPlayFeedbackSound)
    {
        self.feedbackSound.playbackDeviceIdentifier = audioDevice.deviceUID;

        [self.feedbackSound play];
    }

    _audioDeviceSliderInMovement = kAudioObjectUnknown;
}

- (IBAction)masterVolumeMuteCheckBoxChanged:(id)sender
{
    NSButton *button = sender;
    AudioDeviceID audioObjectID = (AudioDeviceID)button.tag;
    AMCoreAudioDevice *audioDevice = [AMCoreAudioDevice deviceWithID:audioObjectID];

    button.toolTip = [button state] ? NSLocalizedString(@"Muted", nil) : NSLocalizedString(@"Unmuted", nil);

    [audioDevice setMute:button.state
              forChannel:kAudioObjectPropertyElementMaster
            andDirection:[audioDevice preferredDirectionForMasterVolume]];
}

- (IBAction)changeCurrentSampleRate:(id)sender
{
    AMCoreAudioDevice *audioDevice = [[sender cell] representedObject];
    Float64 sampleRate = [audioDevice.nominalSampleRates[[sender selectedItem].tag] doubleValue];

    // Try to change sample rate, or refresh affected table row if it fails

    if (![audioDevice setNominalSampleRate:sampleRate])
    {
        [self updateTableColumnWithIdentifier:@"SupportedSampleRates"
                             andAudioObjectID:audioDevice.deviceID];
    }
}

- (IBAction)changeClockSource:(id)sender
{
    AMCoreAudioDevice *audioDevice = [sender representedObject];

    // Change clock source

    [audioDevice setClockSource:[sender title]
                     forChannel:kAudioObjectPropertyElementMaster
                   andDirection:kAMCoreAudioDevicePlaybackDirection];
}

- (IBAction)changeSelectedStatusbarAudioDevice:(id)sender
{
    AMCoreAudioDevice *audioDevice;

    // Update the featured audio device in preferences

    if ([sender selectedItem].tag == kDefaultOuputDevice)
    {
        // Match system's default output device

        audioDevice = [AMCoreAudioDevice defaultOutputDevice];

        [AMPreferences sharedPreferences].device.featuredDeviceUID = (NSString *)kAMNoAudioDevice;
    }
    else
    {
        audioDevice = [[sender cell] representedObject];

        if (audioDevice)
        {
            [AMPreferences sharedPreferences].device.featuredDeviceUID = audioDevice.deviceUID;
            [AMPreferences sharedPreferences].device.featuredDeviceName = audioDevice.deviceName;
        }
    }

    // Update status bar view represented audio device

    [AMStatusBarView sharedInstance].audioDevice = audioDevice;
}

- (IBAction)useDeviceForSoundInput:(id)sender
{
    [[AMCoreAudioManager sharedManager] setDefaultInputDevice:[sender representedObject]];
}

- (IBAction)useDeviceForSoundOutput:(id)sender
{
    [[AMCoreAudioManager sharedManager] setDefaultOutputDevice:[sender representedObject]];
}

- (IBAction)useDeviceForSystemOutput:(id)sender
{
    [[AMCoreAudioManager sharedManager] setDefaultSystemOutputDevice:[sender representedObject]];
}

- (IBAction)toggleShowMasterVolumes:(id)sender
{
    NSString *tooltip = [sender state] ? NSLocalizedString(@"Show Sample Rates", nil) : NSLocalizedString(@"Show Master Volumes", nil);

    [sender setToolTip:tooltip];

    [self showMasterVolumes:[sender state]];
}

- (void)showMasterVolumes:(BOOL)showMasterVolumes
{
    NSInteger idx;
    NSTableColumn *column;

    // Toggle SupportedSampleRates visibility

    idx = [self.tableView columnWithIdentifier:@"SupportedSampleRates"];
    column = self.tableView.tableColumns[idx];

    [column setHidden:showMasterVolumes];

    // Toggle ClockSource visibility

    idx = [self.tableView columnWithIdentifier:@"ClockSource"];
    column = self.tableView.tableColumns[idx];

    [column setHidden:showMasterVolumes];

    // Toggle MasterVolumes visibility

    idx = [self.tableView columnWithIdentifier:@"MasterVolumes"];
    column = self.tableView.tableColumns[idx];

    [column setHidden:!showMasterVolumes];

    // Toggle MasterVolumesExtras visibility

    idx = [self.tableView columnWithIdentifier:@"MasterVolumesExtras"];
    column = self.tableView.tableColumns[idx];

    [column setHidden:!showMasterVolumes];

    // Finally, recalculate key view loop...

    [self.popover.contentViewController.view.window recalculateKeyViewLoop];
}

#pragma mark - Sheet Actions

- (IBAction)displayDeviceActionsSheet:(id)sender
{
    ((NSButton *)sender).state = NSOffState;

    NSWindow *popoverWindow;
    AMCoreAudioDevice *audioDevice;
    AudioObjectID audioObjectID;

    self.popover.behavior = NSPopoverBehaviorApplicationDefined;

    audioObjectID = (AudioObjectID)[sender tag];
    audioDevice = [AMCoreAudioDevice deviceWithID:audioObjectID];

    self.deviceActionsSheet.audioDevice = audioDevice;

    [self.deviceActionsSheet makeFirstResponder:self.deviceActionsSheet.initialFirstResponder];

    popoverWindow = self.popover.contentViewController.view.window;

    [NSApp beginSheet:self.deviceActionsSheet
       modalForWindow:popoverWindow
        modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
          contextInfo:nil];
}

- (IBAction)displayPreferencesSheet:(id)sender
{
    self.popover.behavior = NSPopoverBehaviorApplicationDefined;

    [NSApp beginSheet:self.preferencesSheet
       modalForWindow:self.popover.contentViewController.view.window
        modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
          contextInfo:nil];
}

- (void)sheetDidEnd:(NSWindow *)sheet
         returnCode:(NSInteger)returnCode
        contextInfo:(void *)contextInfo
{
    self.popover.behavior = [AMPreferences sharedPreferences].general.isPopupTransient ? NSPopoverBehaviorTransient : NSPopoverBehaviorSemitransient;
}

#pragma mark - Private Methods

- (void)recalculatePopoverContentSize
{
    if (_originalTableViewHeight == 0.0)
    {
        _originalTableViewHeight = self.tableView.superview.frame.size.height;
    }

    if (_originalPopoverContentHeight == 0.0)
    {
        _originalPopoverContentHeight = self.popover.contentSize.height;
    }

    // We calculate the table view height by summing all the cell heights
    // and taking intercell padding into account

    CGFloat tableViewContentHeight = 0;

    for (int i = 0; i < self.tableView.numberOfRows; i++)
    {
        // Note that this is for view-based tableviews

        NSView *v = [self.tableView viewAtColumn:0
                                             row:i
                                 makeIfNecessary:YES];

        if (v)
        {
            tableViewContentHeight += v.frame.size.height;

            // take intercell padding into account

            tableViewContentHeight += self.tableView.intercellSpacing.height;
        }
    }

    CGFloat deltaY = tableViewContentHeight - _originalTableViewHeight;

    // Resize popover, but only if it is visible
    // but ensuring that the content height is never
    // smaller than originalPopoverContentHeight

    if (self.popover.isShown)
    {
        NSSize popoverContentSize = NSMakeSize(self.popover.contentSize.width,
                                               MAX(_originalPopoverContentHeight,
                                                   _originalPopoverContentHeight + deltaY));

        [self.popover setContentSize:popoverContentSize];
    }
}

- (void)selectFeaturedAudioDevicePopupEntry
{
    NSMenu *popupMenu = self.featuredAudioDevicePopupButton.menu;
    NSMenuItem *selectedMenuItem;

    // Find selected menu item

    NSString *featuredDeviceUID = [AMPreferences sharedPreferences].device.featuredDeviceUID;

    if (featuredDeviceUID)
    {
        if ([kAMNoAudioDevice isEqualToString:featuredDeviceUID])
        {
            selectedMenuItem = [self.featuredAudioDevicePopupButton.menu itemWithTag:kDefaultOuputDevice];
        }
        else
        {
            AMCoreAudioDevice *audioDevice = [AMCoreAudioDevice deviceWithUID:featuredDeviceUID];
            selectedMenuItem = [self.featuredAudioDevicePopupButton.menu itemWithTag:audioDevice.deviceID];
        }
    }
    else
    {
        selectedMenuItem = [self.featuredAudioDevicePopupButton.menu itemWithTitle:NSLocalizedString(@"None", nil)];
    }

    // Still no selection? Device is probably offline.

    if (!selectedMenuItem)
    {
        // Add menu entry for offline device

        NSMenuItem *menuItem = [NSMenuItem new];

        menuItem.title = [NSString stringWithFormat:@"%@ (OFFLINE)", [AMPreferences sharedPreferences].device.featuredDeviceName];

        [popupMenu addItem:menuItem];

        selectedMenuItem = menuItem;
    }

    [self.featuredAudioDevicePopupButton selectItem:selectedMenuItem];
}

- (void)refreshStatusbar
{
    NSMenuItem *selectedMenuItem = self.featuredAudioDevicePopupButton.selectedItem;

    AMCoreAudioDevice *audioDevice;

    if (selectedMenuItem.tag == kDefaultOuputDevice)
    {
        audioDevice = [AMCoreAudioDevice defaultOutputDevice];
    }
    else
    {
        audioDevice = selectedMenuItem.representedObject;
    }

    // Update status bar view represented audio device

    [AMStatusBarView sharedInstance].audioDevice = audioDevice;
}

@end
