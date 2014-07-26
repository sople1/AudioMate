//
//  AMAudioDeviceNameCellView.h
//  AudioMate
//
//  Created by Ruben Nine on 2/26/13.
//  Copyright (c) 2013 Ruben Nine. All rights reserved.
//

#import "AMCellView.h"

@interface AMAudioDeviceNameCellView : AMCellView

@property (assign) IBOutlet NSTextField *nameTextField;
@property (assign) IBOutlet NSTextField *channelLayoutDescriptionTextField;

@end
