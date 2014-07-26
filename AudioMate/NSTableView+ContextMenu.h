//
//  NSTableView+ContextMenu.h
//  AudioMate
//
//  Created by Ruben Nine on 2/26/13.
//  Copyright (c) 2013 Ruben Nine. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ContextMenuDelegate <NSObject>

- (NSMenu*)tableView:(NSTableView*)aTableView menuForRows:(NSIndexSet*)rows;

@end

@interface NSTableView (ContextMenu)

@end
