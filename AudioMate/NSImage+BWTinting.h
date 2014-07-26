//
//  NSImage+BWTinting.h
//  AudioMate
//
//  Created by Ruben Nine on 10/07/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (BWTinting)

- (NSImage *)BWTintedImageWithColor:(NSColor *)tint;

@end
