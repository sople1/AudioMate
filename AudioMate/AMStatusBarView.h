//
//  AudioDeviceStatusBarView.h
//  AudioMate
//
//  Created by Ruben Nine on 27/11/13.
//  Copyright (c) 2013 Ruben Nine. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMPreferences.h"

@class AMCoreAudioDevice;

@interface AMStatusBarView : NSView

@property (nonatomic, retain) AMCoreAudioDevice *audioDevice;
@property (nonatomic, assign) BOOL isHighlighted;
@property (nonatomic) SEL action;
@property (nonatomic, unsafe_unretained) id target;

+ (instancetype)sharedInstance;
- (void)controlTintChanged:(id)sender;

@end
