//
//  AppDelegate.swift
//  Photomania
//
//  Created by Essan Parto on 2014-08-20.
//  Copyright (c) 2014 Essan Parto. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
    UINavigationBar.appearance().barStyle = .BlackTranslucent
    UINavigationBar.appearance().tintColor = UIColor.whiteColor()
    
    UIToolbar.appearance().barStyle = .BlackTranslucent
    UITabBar.appearance().barStyle = .Black
    UITabBar.appearance().translucent = true
    UITabBar.appearance().tintColor = UIColor.whiteColor()
    
    UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()
    
    UIButton.appearance().tintColor = UIColor.whiteColor()
    
    return true
  }
}

