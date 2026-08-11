import SwiftUI
import UIKit

extension View {
    /// Renders this view to a `UIImage` for sharing/exporting.
    ///
    /// Plain `ImageRenderer` can come back with a blank first frame for content
    /// containing `Canvas` (used by the pitch markings) or Material effects, because
    /// without an explicit `proposedSize` it has to resolve `GeometryReader`-driven
    /// layout itself, and that resolution isn't always complete on the first access.
    /// Giving it a concrete proposed size, and discarding one "warm-up" render before
    /// the real one, produces a reliably fully-composited image.
    @MainActor
    func renderedToImage(width: CGFloat, scale: CGFloat = 3) -> UIImage? {
        let height = UIHostingController(rootView: self)
            .sizeThatFits(in: CGSize(width: width, height: .greatestFiniteMagnitude))
            .height

        let renderer = ImageRenderer(content: self)
        renderer.scale = scale
        renderer.isOpaque = true
        renderer.proposedSize = ProposedViewSize(width: width, height: max(height, 1))

        _ = renderer.uiImage
        return renderer.uiImage
    }
}
