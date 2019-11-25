//
//  File.swift
//  imglyKit iOS
//
//  Created by Мурат Камалов on 22.11.2019.
//  Copyright © 2019 9elements GmbH. All rights reserved.
//

#if os(iOS)
import UIKit
import CoreImage
#elseif os(OSX)
import AppKit
import QuartzCore
#endif

import CoreGraphics



open class IMGLYDrawFilter: CIFilter {
    /// A CIImage object that serves as input for the filter.
    @objc open var inputImage: CIImage?

    /// The paint that should be rendered.
    #if os(iOS)
    open var paint: UIImage?
    #elseif os(OSX)
    public var paint: NSImage?
    #endif

    /// The transform to apply to the paint
    open var transform = CGAffineTransform.identity

    /// The relative center of the paint within the image.
    open var center = CGPoint()

    /// The relative scale of the paint within the image.
    open var scale = CGFloat(1.0)

    override init() {
        super.init()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /// Returns a CIImage object that encapsulates the operations configured in the filter. (read-only)
    open override var outputImage: CIImage? {
        guard let inputImage = inputImage else {
            return nil
        }

        if paint == nil {
            return inputImage
        }

        let paintImage = createpaintImage()

        guard let cgImage = paintImage.cgImage, let filter = CIFilter(name: "CISourceOverCompositing") else {
            return inputImage
        }

        let paintCIImage = CIImage(cgImage: cgImage)
        filter.setValue(inputImage, forKey: kCIInputBackgroundImageKey)
        filter.setValue(paintCIImage, forKey: kCIInputImageKey)
        return filter.outputImage
    }

    open func absolutpaintSizeForImageSize(_ imageSize: CGSize) -> CGSize {
        let paintRatio = paint!.size.height / paint!.size.width
        return CGSize(width: self.scale * imageSize.width, height: self.scale * paintRatio * imageSize.width)
    }

    #if os(iOS)

    fileprivate func createpaintImage() -> UIImage {
        let rect = inputImage!.extent
        let imageSize = rect.size
        UIGraphicsBeginImageContext(imageSize)
        UIColor(white: 1.0, alpha: 0.0).setFill()
        UIRectFill(CGRect(origin: CGPoint(), size: imageSize))

        if let context = UIGraphicsGetCurrentContext() {
            drawpaintInContext(context, withImageOfSize: imageSize)
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }

    #elseif os(OSX)

    private func createpaintImage() -> NSImage {
        let rect = inputImage!.extent
        let imageSize = rect.size

        let image = NSImage(size: imageSize)
        image.lockFocus()
        NSColor(white: 1, alpha: 0).setFill()
        CGRect(origin: CGPoint(), size: imageSize).fill()

        let context = NSGraphicsContext.current!.cgContext
        drawpaintInContext(context, withImageOfSize: imageSize)

        image.unlockFocus()

        return image
    }

    #endif

    fileprivate func drawpaintInContext(_ context: CGContext, withImageOfSize imageSize: CGSize) {
        context.saveGState()

        let center = CGPoint(x: self.center.x * imageSize.width, y: self.center.y * imageSize.height)
        let size = self.absolutpaintSizeForImageSize(imageSize)
        let imageRect = CGRect(origin: center, size: size)

        // Move center to origin
        context.translateBy(x: imageRect.origin.x, y: imageRect.origin.y)
        // Apply the transform
        context.concatenate(self.transform)
        // Move the origin back by half
        context.translateBy(x: imageRect.size.width * -0.5, y: imageRect.size.height * -0.5)

        paint?.draw(in: CGRect(origin: CGPoint(), size: size))
        context.restoreGState()
    }
}

extension IMGLYDrawFilter {
    open override func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! IMGLYDrawFilter
        copy.inputImage = inputImage?.copy(with: zone) as? CIImage
        copy.paint = paint
        copy.center = center
        copy.scale = scale
        copy.transform = transform
        return copy
    }
}
