//
//  NSTimer+EOCBlocksSupport.h
//  AudioMaestro
//
//  Created by Ruben Nine on 23/02/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (EOCBlocksSupport)

+ (NSTimer*)eoc_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                         block:(void (^)())block
                                       repeats:(BOOL)repeats;

@end
