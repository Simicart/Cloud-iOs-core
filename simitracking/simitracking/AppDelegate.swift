//
//  AppDelegate.swift
//  simitracking
//
//  Created by Hai Nguyen on 11/5/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit
import Mixpanel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIAlertViewDelegate {

    var window: UIWindow?
    private var orderId: String = ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let loginVC = STLoginViewController()
        // For remote Notification
        loginVC.orderId = ""
//        if let launchOpts = launchOptions {
//            if let notificationPayload: NSDictionary = launchOpts[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary{
//                self.application(application, didReceiveRemoteNotification: notificationPayload as! [AnyHashable : Any], fetchCompletionHandler: { (UIBackgroundFetchResult) in
//                })
//                loginVC.orderId = orderId
////                let aps = notificationPayload["aps"] as! NSDictionary
////                showAlertWithTitle("", message: "\(aps)")
////                let orderId = aps["order_id"] as! String
////                loginVC.orderId = orderId
//            }
//        }
        if let notification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: AnyObject] {
            let aps = notification["aps"] as! [String: AnyObject]
            orderId = aps["order_id"] as! String
            loginVC.orderId = orderId
        }
        SimiGlobalVar.updateLayoutDirection()
        //notification token getting
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController = loginVC
        
        let token = "286b4016149732004b4ebb2f2891ffec"
        Mixpanel.initialize(token: token)
        return true
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
//        UIApplication.shared.applicationIconBadgeNumber = 0
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DidReceiveRemoteNotification"), object: userInfo)
        if STUserData.sharedInstance.isLoggedIn{
            if let aps = userInfo["aps"] as? NSDictionary {
                let title = aps["title"] as? NSString as? String
                let alert = aps["alert"] as? NSString as? String
                //let message = aps["message"] as? NSString as? String
                orderId = (aps["order_id"] as? NSString as? String)!
                //check app state
                let state = UIApplication.shared.applicationState
                if state == .background {
                }else if(state == .active){
                    let alertView = UIAlertView(title: title!, message: alert!, delegate: self, cancelButtonTitle: STLocalizedString(inputString: "OK"), otherButtonTitles: STLocalizedString(inputString: "Show Order"))
                    alertView.show()
                }else if(state == .inactive){
                    let orderDetailVC = STOrderDetailViewController()
                    orderDetailVC.orderId = orderId
                    if let mainNavigation = STLeftMenuViewController.shareInstance.mainNavigation{
    //                    mainNavigation.popToRootViewController(animated: false)
                        mainNavigation.pushViewController(orderDetailVC, animated: false)
                        mainNavigation.navigationItem.setHidesBackButton(false, animated: false)
                        orderDetailVC.navigationItem.leftBarButtonItem = STLeftMenuViewController.shareInstance.mainNavigation.menuButton
                    }else{
                        
                    }
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var tokenString = ""
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        //Save device token id
        STUserData.sharedInstance.deviceTokenId = tokenString
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        showAlertWithTitle("", message: "\(error)")
    }
    
    //Show message for order push notification
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if(buttonIndex == 1){
            if STUserData.sharedInstance.isLoggedIn{
                let orderDetailVC = STOrderDetailViewController()
                orderDetailVC.orderId = orderId
    //            STLeftMenuViewController.shareInstance.mainNavigation.popToRootViewController(animated: false)
                STLeftMenuViewController.shareInstance.mainNavigation.pushViewController(orderDetailVC, animated: false)
                STLeftMenuViewController.shareInstance.mainNavigation.navigationItem.setHidesBackButton(false, animated: false)
                orderDetailVC.navigationItem.leftBarButtonItem = STLeftMenuViewController.shareInstance.mainNavigation.menuButton
            }
        }
    }
}

