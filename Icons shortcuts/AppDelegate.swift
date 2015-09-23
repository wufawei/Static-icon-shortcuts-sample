//
//  AppDelegate.swift
//  Icons shortcuts


import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    enum ShortcutType: String {
        case Green = "Green"
        case Red =   "Red"
    
        
    }
    
    var window: UIWindow?

    static let applicationShortcutUserInfoIconKey = "applicationShortcutUserInfoIconKey"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        var launchedFromShortCut = false
        //Check for ShortCutItem
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
            launchedFromShortCut = true
            handleShortCutItem(shortcutItem)
        }
        
        let item1  = UIApplicationShortcutItem(type: ShortcutType.Green.rawValue, localizedTitle: "dynamic shortcut 1, green")
        let item2  = UIApplicationShortcutItem(type: ShortcutType.Red.rawValue, localizedTitle: "dynamic shortcut 2, red")
        let item3  = UIApplicationShortcutItem(type: ShortcutType.Green.rawValue, localizedTitle: "dynamic shortcut 3, green")
        let item4  = UIApplicationShortcutItem(type: ShortcutType.Red.rawValue, localizedTitle: "dynamic shortcut 4, red")
        let item5  = UIApplicationShortcutItem(type: ShortcutType.Green.rawValue, localizedTitle: "dynamic shortcut 5, green")
        
        application.shortcutItems = [item1, item2, item3, item4, item5]
        
        // Return false incase application was lanched from shorcut to prevent
        // application(_:performActionForShortcutItem:completionHandler:) from being called
        return !launchedFromShortCut
    }

    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: Bool -> Void) {
        let handledShortCutItem = handleShortCutItem(shortcutItem)
        completionHandler(handledShortCutItem)
    }
    
    func handleShortCutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {
        var handled = false
        //Get type string from shortcutItem
        if let shortcutType = ShortcutType.init(rawValue: shortcutItem.type) {
            //Get root navigation viewcontroller and its first controller
            let rootNavigationViewController = window!.rootViewController as? UINavigationController
            let rootViewController = rootNavigationViewController?.viewControllers.first as UIViewController?
            //Pop to root view controller so that approperiete segue can be performed
            rootNavigationViewController?.popToRootViewControllerAnimated(false)
            
            switch shortcutType {
            case .Green:
                rootViewController?.performSegueWithIdentifier(toGreenSeque, sender: nil)
                handled = true
            case.Red:
                rootViewController?.performSegueWithIdentifier(toRedSeque, sender: nil)
                handled = true
            }
        }
        
        
        // 这里还可以动态设置，关闭添加的快捷选项。
        // UIApplication.sharedApplication().shortcutItems = nil
        
        return handled
    }
}

