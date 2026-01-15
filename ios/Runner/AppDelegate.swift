import UIKit
import Flutter
import Firebase // Required for native initialization

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Initialize Firebase natively before any plugins register.
    // This prevents crashes if plugins expect Firebase to be ready.
    if FirebaseApp.app() == nil {
        FirebaseApp.configure()
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
