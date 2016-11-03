//
//  AppDelegate.m
//  DMZTouchesWindowSample
//
//  Created by dmoroz0v on 02/11/16.
//  Copyright © 2016 DMZ. All rights reserved.
//

#import "AppDelegate.h"

#import "DMZTouchesWindow.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	DMZTouchesWindow *window = [[DMZTouchesWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
	window.dmz_touchesEnabled = YES;

	self.window = window;
	self.window.rootViewController = [[ViewController alloc] init];
	[self.window makeKeyAndVisible];

	return YES;
}

@end
