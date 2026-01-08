import UIKit
import Flutter
import Firebase // Required for native Firebase initialization

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // 1. Initialize Firebase before anything else.
    // This prevents the 'Missing GoogleService-Info.plist' crash on startup.
    if FirebaseApp.app() == nil {
        FirebaseApp.configure()
    }

    // 2. Register all Flutter plugins (including OneSignal and Stripe).
    GeneratedPluginRegistrant.register(with: self)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
