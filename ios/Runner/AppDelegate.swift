import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging
import FirebaseAuth

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

 override init() {
    super.init()
    FirebaseApp.configure()
  }
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
