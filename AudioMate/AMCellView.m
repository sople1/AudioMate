//
//  AMCellView.m
//  AudioMate
//
//  Created by Ruben Nine on 10/07/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import "AMCellView.h"

@implementation AMCellView

- (void)populateWithAudioDevice:(AMCoreAudioDevice *)audioDevice
{
    NSAssert(true, @"Must be overriden by subclasses");
}

@end
