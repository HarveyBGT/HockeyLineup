import SwiftUI
import UIKit

extension View {
    /// Renders this view to a `UIImage` by briefly hosting it in a real, off-screen
    /// `UIWindow`. `ImageRenderer` on its own is unreliable for content containing
    /// `Canvas` (used by the pitch markings) or Material effects — without being
    /// composited by an actual window, those layers can come back blank. Attaching
    /// to a real window forces a proper render pass before we snapshot it.
    @MainActor
    func renderedToImage(width: CGFloat, scale: CGFloat = 3) -> UIImage? {
        let controller = UIHostingController(rootView: self)
        let fitSize = controller.sizeThatFits(in: CGSize(width: width, height: .greatestFiniteMagnitude))
        let size = CGSize(width: width, height: max(fitSize.height, 1))

        let window = UIWindow(frame: CGRect(x: 0, y: -size.height - 200, width: size.width, height: size.height))
        window.windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        window.rootViewController = controller
        controller.view.frame = CGRect(origin: .zero, size: size)
        window.isHidden = false
        window.layoutIfNeeded()

        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = true
        let image = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }

        window.isHidden = true
        window.rootViewController = nil
        return image
    }
}
