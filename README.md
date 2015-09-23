### 15分钟掌握iOS9 3D Touch的Quick Actions

苹果在iOS 9中引入的 3D touch功能，相关的API分为3个部分：

- Quick actions
- Peek and Pop
- Pressure Sensitivity。

在iPhone 6s或者 iPhone 6s Plus上，当用户按压app icon的时候，会弹出Quick Action，当用户选择其中的action的时候，app会启动并接收到相应的消息。

####  开发环境
官方文档说用Xcode 7.0，你必须使用支持 3D Touch的设备进行调试，Xcode 7.0上的模拟器不支持 3D Touch。


@conradev开源的SBShortcutMenuSimulator让我们可以在Xcode 7.0上使用模拟器进行调试。

**Build**

按照https://github.com/DeskConnect/SBShortcutMenuSimulator上给出的文档进行操作。

在Mac的Termnial执行：
git clone https://github.com/DeskConnect/SBShortcutMenuSimulator.git

cd SBShortcutMenuSimulator

make



**开启模拟器后运行**

在Mac的Termnial执行：

xcrun simctl spawn booted launchctl debug system/com.apple.SpringBoard --environment DYLD_INSERT_LIBRARIES=$PWD/SBShortcutMenuSimulator.dylib

xcrun simctl spawn booted launchctl stop com.apple.SpringBoard


下面的命令可以在模拟器上显示日历的Quick Action
echo 'com.apple.mobilecal' | nc 127.0.0.1 8000


你只需要把echo后面的bundle id换成你自己的demo的build id就可以进行测试了。


继续介绍如何给你的App加上Quick Actions的支持。

#### Home Screen Quick Actions


Quick Actions分为2类:static与dynamic。

- static quick actions。
    
   在App的Info.plist文件中UIApplicationShortcutItems这个数组中定义。UIApplicationShortcutItems的每一项都需要定义UIApplicationShortcutItemType、
UIApplicationShortcutItemTitle、其它字段都是optional的。如下图所示：


- dynamic quick actions

  设置UIApplication对象的shortCutItems属性动态创建UIApplicationShortcutItem。
  
  
**如何响应用户的操作**

app delegate中的application(_:performActionForShortcutItem:completionHandler:)用来响应用户的操作。可以在这里处理响应的action(static与dynamic都在此处理)。

####相关代码


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
        
        
        // 这里还可以动态设置，关闭添加的Quick Action。
        // UIApplication.sharedApplication().shortcutItems = nil
        
        return handled
     }
    }




需要注意的是，如果app启动的时候（比如之前app被kill掉），需要在 application:didFinishLaunchingWithOptions: 或者application:willFinishLaunchingWithOptions:中检查检查launchOptions字典中的UIApplicationLaunchOptionsShortcutItemKey来判断是否是通过Quick Action进入的app。

如果确实是从Quick Action进入的app，在application:didFinishLaunchingWithOptions:中处理完响应的action之后，需要返回false。这样可以避免application(_:performActionForShortcutItem:completionHandler:)被调用到。



#### Quick Actions最多为4个

最多可以显示4个Quick Action（静态和动态算在一起）。上图可以看到，我们定义了2个静态的，试图添加5个动态的Quick Action，

        application.shortcutItems = [item1, item2, item3, item4, item5]

但是只有item1, item2生效。

测试发现，动态添加Quick Action成功之后，即使系统重启，下次打开依然有效。第一次全新安装（但是不运行App），只会显示静态的Quick Action。（如有谬误，敬请指正，谢谢）

### 总结
发挥你的创意，给你的App添加Quick Action支持，让用户获得更好的体验吧。

#### 参考文档
https://developer.apple.com/library/prerelease/ios/documentation/UserExperience/Conceptual/Adopting3DTouchOniPhone/index.html#//apple_ref/doc/uid/TP40016543-CH1-SW1

https://developer.apple.com/library/prerelease/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/iPhoneOSKeys.html#//apple_ref/doc/uid/TP40009252-SW36

https://developer.apple.com/library/prerelease/ios/samplecode/ApplicationShortcuts/Introduction/Intro.html#//apple_ref/doc/uid/TP40016545-Intro-DontLinkElementID_2

https://github.com/DeskConnect/SBShortcutMenuSimulator

http://www.stringcode.co.uk/add-ios-9s-quick-actions-shortcut-support-in-15-minutes-right-now/




