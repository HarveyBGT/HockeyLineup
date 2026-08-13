// Generates the three iOS 18+ app icon appearance variants (Any/Light,
// Dark, Tinted) as opaque 1024x1024 PNGs — a bold gold crenellated shield
// on a navy gradient, matching Theme.swift's palette.
//
// Run once per variant, then copy the outputs into
// Resources/Assets.xcassets/AppIcon.appiconset/ (as icon-1024.png,
// icon-1024-dark.png, icon-1024-tinted.png) and re-run
// ./Scripts/generate_project.sh:
//
//   swift Scripts/make_icon.swift light  /tmp/icon-light.png
//   swift Scripts/make_icon.swift dark   /tmp/icon-dark.png
//   swift Scripts/make_icon.swift tinted /tmp/icon-tinted.png
//
// IMPORTANT: iOS app icons must be fully opaque with no alpha channel — one
// with an alpha channel (even fully-opaque pixels) silently falls back to a
// placeholder icon on the Home Screen instead of failing the build. That's
// why the bitmap context below is `.noneSkipLast`, not `.premultipliedLast`.
// The "tinted" variant must also be grayscale (no hue) — the system applies
// the user's chosen Home Screen tint colour over its luminosity values.
import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

// Usage: swift make_icon.swift <light|dark|tinted> <outputPath>
let mode = CommandLine.arguments[1]
let outputPath = CommandLine.arguments[2]

let canvas: CGFloat = 1024
let ctx = CGContext(
    data: nil, width: Int(canvas), height: Int(canvas),
    bitsPerComponent: 8, bytesPerRow: 0,
    space: CGColorSpaceCreateDeviceRGB(),
    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
)!

func rgb(_ r: Int, _ g: Int, _ b: Int, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: a)
}
// Grayscale helper for the "tinted" appearance — Apple's guidance is a
// monochrome/luminosity-only image; the system applies the user's chosen
// tint colour over it at display time.
func gray(_ v: Int, _ a: CGFloat = 1) -> CGColor { rgb(v, v, v, a) }

// MARK: - Background
switch mode {
case "light":
    let bgColors = [rgb(0x0B, 0x25, 0x45), rgb(0x16, 0x50, 0x8A), rgb(0x17, 0x2E, 0x40)] as CFArray
    let bgGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: bgColors, locations: [0, 0.55, 1])!
    ctx.drawLinearGradient(bgGradient, start: CGPoint(x: 0, y: canvas), end: CGPoint(x: canvas, y: 0), options: [])
    if let glow = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [rgb(0x2E, 0x74, 0xB8, 0.35), rgb(0x2E, 0x74, 0xB8, 0)] as CFArray, locations: [0, 1]) {
        ctx.drawRadialGradient(glow, startCenter: CGPoint(x: canvas * 0.32, y: canvas * 0.78), startRadius: 0, endCenter: CGPoint(x: canvas * 0.32, y: canvas * 0.78), endRadius: canvas * 0.55, options: [])
    }
case "dark":
    // Deeper, near-black background so the icon sits naturally among other
    // dark-appearance icons instead of reading as a lighter blue square.
    let bgColors = [rgb(0x05, 0x12, 0x22), rgb(0x0A, 0x28, 0x48), rgb(0x06, 0x0E, 0x16)] as CFArray
    let bgGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: bgColors, locations: [0, 0.55, 1])!
    ctx.drawLinearGradient(bgGradient, start: CGPoint(x: 0, y: canvas), end: CGPoint(x: canvas, y: 0), options: [])
default: // tinted — grayscale only, no hue; the system recolours this itself.
    let bgColors = [gray(18), gray(46), gray(12)] as CFArray
    let bgGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: bgColors, locations: [0, 0.55, 1])!
    ctx.drawLinearGradient(bgGradient, start: CGPoint(x: 0, y: canvas), end: CGPoint(x: canvas, y: 0), options: [])
}

// MARK: - Shield geometry (shared across all three appearances)
let shieldW = canvas * 0.56
let shieldH = canvas * 0.66
let originX = (canvas - shieldW) / 2
let shieldTopY = canvas * 0.80
let merlonHeight = shieldH * 0.115

func p(_ fracX: CGFloat, _ fracYFromTop: CGFloat) -> CGPoint {
    CGPoint(x: originX + fracX * shieldW, y: shieldTopY - fracYFromTop * shieldH)
}

let merlons: [(CGFloat, CGFloat)] = [(0.0, 0.22), (0.39, 0.61), (0.78, 1.0)]

let shield = CGMutablePath()
var startedPath = false
for m in merlons {
    let leftBase = p(m.0, 0)
    let leftPeak = CGPoint(x: leftBase.x, y: leftBase.y + merlonHeight)
    let rightPeak = CGPoint(x: p(m.1, 0).x, y: leftBase.y + merlonHeight)
    let rightBase = p(m.1, 0)

    if !startedPath {
        shield.move(to: leftBase)
        startedPath = true
    } else {
        shield.addLine(to: leftBase)
    }
    shield.addLine(to: leftPeak)
    shield.addLine(to: rightPeak)
    shield.addLine(to: rightBase)
}

let bottomPoint = p(0.5, 1.0)
shield.addQuadCurve(to: bottomPoint, control: p(1.05, 0.86))
shield.addQuadCurve(to: p(0.0, 0), control: p(-0.05, 0.86))
shield.closeSubpath()

// MARK: - Drop shadow pass
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -18), blur: 46, color: rgb(0x00, 0x00, 0x00, mode == "tinted" ? 0.55 : 0.45))
ctx.addPath(shield)
ctx.setFillColor(mode == "tinted" ? gray(235) : rgb(0xC9, 0x96, 0x2C))
ctx.fillPath()
ctx.restoreGState()

// MARK: - Shield fill
ctx.saveGState()
ctx.addPath(shield)
ctx.clip()
let fillColors: CFArray
switch mode {
case "tinted":
    fillColors = [gray(252), gray(225), gray(180)] as CFArray
default:
    fillColors = [rgb(0xEE, 0xD4, 0x9A), rgb(0xC9, 0x96, 0x2C), rgb(0x93, 0x66, 0x18)] as CFArray
}
let fillGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: fillColors, locations: [0, 0.5, 1])!
ctx.drawLinearGradient(fillGradient, start: CGPoint(x: canvas / 2, y: shieldTopY + merlonHeight), end: bottomPoint, options: [])
ctx.restoreGState()

// MARK: - Inner sheen
ctx.saveGState()
ctx.addPath(shield)
ctx.clip()
let sheenAlpha: CGFloat = mode == "tinted" ? 0.22 : 0.32
if let sheen = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [rgb(255, 255, 255, sheenAlpha), rgb(255, 255, 255, 0)] as CFArray, locations: [0, 1]) {
    ctx.drawLinearGradient(sheen, start: CGPoint(x: originX + shieldW * 0.15, y: shieldTopY + merlonHeight), end: CGPoint(x: originX + shieldW * 0.55, y: shieldTopY - shieldH * 0.55), options: [])
}
ctx.restoreGState()

// MARK: - Outline
ctx.addPath(shield)
ctx.setStrokeColor(mode == "tinted" ? gray(10) : rgb(0x0B, 0x25, 0x45))
ctx.setLineWidth(canvas * 0.014)
ctx.setLineJoin(.round)
ctx.setLineCap(.round)
ctx.strokePath()

// MARK: - Export
guard let image = ctx.makeImage() else { fatalError("Could not render image") }
let outputURL = URL(fileURLWithPath: outputPath)
guard let destination = CGImageDestinationCreateWithURL(outputURL as CFURL, UTType.png.identifier as CFString, 1, nil) else {
    fatalError("Could not create image destination")
}
CGImageDestinationAddImage(destination, image, nil)
guard CGImageDestinationFinalize(destination) else { fatalError("Could not write PNG") }
print("Wrote \(outputURL.path)")
