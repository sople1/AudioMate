//
//  AMAudioDeviceMasterVolumesCellView.h
//  AudioMate
//
//  Created by Ruben Nine on 8/1/13.
//  Copyright (c) 2013 Ruben Nine. All rights reserved.
//

#import "AMCellView.h"

@interface AMAudioDeviceMasterVolumesCellView : AMCellView

@property (assign) IBOutlet NSSlider *masterVolumesSlider;
@property (assign) IBOutlet NSButton *masterVolumeLockCheckbox;

@end
