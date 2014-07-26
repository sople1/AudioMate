//
//  AMAudioDeviceSampleRatesCellView.m
//  AudioMate
//
//  Created by Ruben Nine on 2/26/13.
//  Copyright (c) 2013 Ruben Nine. All rights reserved.
//

#import "AMSampleRatePopUpButtonCellView.h"
#import <AMCoreAudio/AMCoreAudio.h>
#import "AMCoreAudioDevice+Formatters.h"

@implementation AMSampleRatePopUpButtonCellView

- (void)populateWithAudioDevice:(AMCoreAudioDevice *)audioDevice
{
    NSArray *nominalSampleRates;

    [self.popUpButton removeAllItems];

    self.popUpButton.target = self.target;
    self.popUpButton.action = self.action;

    nominalSampleRates = audioDevice.nominalSampleRates;

    if (nominalSampleRates.count == 0)
    {
        [self.popUpButton addItemWithTitle:NSLocalizedString(@"N/A", nil)];
        [self.popUpButton selectItemAtIndex:0];

        self.popUpButton.enabled = NO;
    }
    else
    {
        [nominalSampleRates enumerateObjectsUsingBlock: ^(id entry, NSUInteger idx, BOOL *stop)
        {
            NSNumber *sampleRate;
            NSString *formattedSampleRate;

            sampleRate = entry;
            formattedSampleRate = [AMCoreAudioDevice formattedSampleRate:sampleRate.floatValue
                                                          useShortFormat:NO];

            [self.popUpButton addItemWithTitle:formattedSampleRate];

            // Get the newly appended menu item

            NSMenuItem *menuItem = self.popUpButton.lastItem;

            menuItem.representedObject = audioDevice;

            // We will use the tag later to get the supportedSampleRates array index
            // in lack on a cleaner alternative

            menuItem.tag = idx;
        }];

        NSString *currentSampleRateString = [audioDevice actualSampleRateFormattedWithShortFormat:NO];

        [self.popUpButton selectItemWithTitle:currentSampleRateString];

        self.popUpButton.enabled = YES;
    }
}

@end
