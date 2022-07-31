//
//  AppDelegate.swift
//  DMZTouchesWindowSample
//
//  Created by dmoroz0v on 05/11/16.
//  Copyright © 2016 DMZ. All rights reserved.
//

import UIKit
import DMZTouchesWindow

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
	{
		let window = DMZTouchesWindow(frame: UIScreen.main.bounds);
		window.dmz_touchesEnabled = true

		self.window = window
		self.window?.rootViewController = ViewController();
		self.window?.makeKeyAndVisible()

		return true
	}
}
