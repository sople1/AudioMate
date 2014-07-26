//
//  AMAudioDevicePopulatableTableCellProtocol.h
//  AudioMate
//
//  Created by Ruben Nine on 10/07/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AMCoreAudioDevice;

@protocol AMAudioDevicePopulatableTableCellViewProtocol <NSObject>

- (void)populateWithAudioDevice:(AMCoreAudioDevice *)audioDevice;

@end
