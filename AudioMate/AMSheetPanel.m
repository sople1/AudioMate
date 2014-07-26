//
//  AMSheetPanel.m
//  AudioMate
//
//  Created by Ruben Nine on 10/07/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import "AMSheetPanel.h"

@implementation AMSheetPanel

- (IBAction)closeSheet:(id)sender
{
    // In the case that the focus was on a text field,
    // this will force the text field to end editing
    // so changes to the field can be confirmed before closing the sheet

    [self makeFirstResponder:nil];

    // End sheet and order out

    [NSApp endSheet:self];
    [self orderOut:sender];
}

@end
