//
//  AMAudioDeviceDefaultsCellView.h
//  AudioMate
//
//  Created by Ruben Nine on 2/26/13.
//  Copyright (c) 2013 Ruben Nine. All rights reserved.
//

#import "AMCellView.h"

@interface AMAudioDeviceDefaultsCellView : AMCellView

@property (assign) IBOutlet NSImageView *defaultInputImageView;
@property (assign) IBOutlet NSImageView *defaultOutputImageView;
@property (assign) IBOutlet NSImageView *defaultSystemOutputImageView;

@end
