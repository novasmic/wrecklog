import Flutter
import UIKit
import AppTrackingTransparency
import FBSDKCoreKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Initialise Facebook SDK
    ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

    // Request ATT permission after a short delay so the app UI is visible first.
    if #available(iOS 14, *) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        ATTrackingManager.requestTrackingAuthorization { status in
          // Enable Facebook advertiser tracking based on ATT result
          if #available(iOS 14, *) {
            Settings.shared.isAdvertiserTrackingEnabled = (status == .authorized)
            Settings.shared.isAdvertiserIDCollectionEnabled = (status == .authorized)
          }
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
