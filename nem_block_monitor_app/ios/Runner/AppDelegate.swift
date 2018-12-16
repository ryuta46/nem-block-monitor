import UIKit
import Flutter
import NemSwift

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let methodChannel = FlutterMethodChannel(name: "nemblockmonitorapp.ttechsoft.com/nem",
                                              binaryMessenger: controller)
    methodChannel.setMethodCallHandler({ (call: FlutterMethodCall, result: FlutterResult) -> Void in
        switch call.method {
        case "calculateAddress":
            if let arguments = call.arguments as? Dictionary<String, Any> {
                guard let publicKey = arguments["publicKey"] as? String,
                    let networkTypeValue = arguments["networkType"] as? UInt8,
                    let networkType = Address.Network(rawValue: networkTypeValue) else {
                        result(FlutterError(code: "Invalid argument", message: "Argument type is not valid", details: nil))
                        return
                }

                let address = Address(publicKey:  ConvertUtil.toByteArray(publicKey), network: networkType)
                result(address.value)
                return
            }
        case "toOssLicense":
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        default:
            result(FlutterMethodNotImplemented)
            break
//            let networkType:
//            0x68 -> Version.Main
//            else -> Version.Test
//            }
            
//            val address = AccountGenerator.calculateAddress(ConvertUtils.toByteArray(publicKey!!), networkType)
//            result.success(address)
  //          }

        }
        
        // Handle battery messages.
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
