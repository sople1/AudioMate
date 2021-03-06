//
//  AppDelegate.h
//  AudioMate
//
//  Created by Ruben Nine on 12/2/12.
//  Copyright (c) 2012 Ruben Nine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Growl/Growl.h>
#import "AMPopoverController.h"

@interface AMAppDelegate : NSObject <NSApplicationDelegate,
                                     AMPopoverControllerDelegate,
                                     GrowlApplicationBridgeDelegate>

@property (assign) IBOutlet AMPopoverController *popoverController;

@end
