//
//  AMCellView.h
//  AudioMate
//
//  Created by Ruben Nine on 10/07/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMAudioDevicePopulatableTableCellViewProtocol.h"

@interface AMCellView : NSTableCellView <AMAudioDevicePopulatableTableCellViewProtocol>

@property (nonatomic) SEL action;
@property (nonatomic, unsafe_unretained) id target;

- (void)populateWithAudioDevice:(AMCoreAudioDevice *)audioDevice;

@end
