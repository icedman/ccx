//
//  AppDelegate.h
//  Cocos 2d Extensions
//
//  Created by Marvin Sanchez on 5/10/13.
//  Copyright Marvin Sanchez 2013. All rights reserved.
//

#import "cocos2d.h"

@interface Cocos_2d_ExtensionsAppDelegate : NSObject <NSApplicationDelegate>
{
	NSWindow	*window_;
	CCGLView	*glView_;
}

@property (assign) IBOutlet NSWindow	*window;
@property (assign) IBOutlet CCGLView	*glView;

- (IBAction)toggleFullScreen:(id)sender;

@end
