import Flutter
import UIKit
import AppTrackingTransparency

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Request ATT permission after a short delay so the app UI is visible first.
    // The Facebook SDK reads ATT status automatically once permission is granted/denied.
    if #available(iOS 14, *) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        ATTrackingManager.requestTrackingAuthorization { _ in }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
