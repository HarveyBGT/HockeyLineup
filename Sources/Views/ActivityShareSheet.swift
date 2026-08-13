import SwiftUI
import UIKit

/// Presents a `UIActivityViewController` imperatively via UIKit instead of
/// through a SwiftUI `.sheet`. The `.sheet`-wrapped `UIViewControllerRepresentable`
/// version of this is a well-known source of a blank/white share sheet on real
/// devices — the activity controller's content sometimes never lays out
/// because it isn't attached to the window in time. Presenting it directly
/// from the topmost view controller avoids that entirely.
enum ActivityShareSheet {
    @MainActor
    static func present(items: [Any]) {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
            let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController
        else { return }

        var topViewController = rootViewController
        while let presented = topViewController.presentedViewController {
            topViewController = presented
        }

        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        // iPad requires a popover source or it silently fails to present;
        // harmless to set on iPhone too.
        activityViewController.popoverPresentationController?.sourceView = topViewController.view
        activityViewController.popoverPresentationController?.sourceRect = CGRect(
            x: topViewController.view.bounds.midX,
            y: topViewController.view.bounds.midY,
            width: 0,
            height: 0
        )
        topViewController.present(activityViewController, animated: true)
    }
}
