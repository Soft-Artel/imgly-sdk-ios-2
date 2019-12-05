//
//  IMGLYInstanceFactoryExtension.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 30/05/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation
import CoreGraphics

extension IMGLYInstanceFactory {
    // MARK: - Editor View Controllers
    
    /**
    Return the viewcontroller according to the button-type.
    This is used by the main menu.
    
    - parameter type: The type of the button pressed.
    
    - returns: A viewcontroller according to the button-type.
    */
    public class func viewControllerForButtonType(_ type: IMGLYMainMenuButtonType, withFixedFilterStack fixedFilterStack: IMGLYFixedFilterStack, and frame: CGRect? = nil, doneEditDelegate: DoneEditDelegate?) -> IMGLYSubEditorViewController? {
        switch (type) {
        case IMGLYMainMenuButtonType.filter:
            return filterEditorViewControllerWithFixedFilterStack(fixedFilterStack, doneEditDelegate)
        case IMGLYMainMenuButtonType.stickers:
            return stickersEditorViewControllerWithFixedFilterStack(fixedFilterStack, doneEditDelegate)
        case IMGLYMainMenuButtonType.orientation:
            return orientationEditorViewControllerWithFixedFilterStack(fixedFilterStack, doneEditDelegate)
        case IMGLYMainMenuButtonType.focus:
            return focusEditorViewControllerWithFixedFilterStack(fixedFilterStack, doneEditDelegate)
        case IMGLYMainMenuButtonType.crop:
            return cropEditorViewControllerWithFixedFilterStack(fixedFilterStack, doneEditDelegate)
        case IMGLYMainMenuButtonType.brightness:
            return brightnessEditorViewControllerWithFixedFilterStack(fixedFilterStack, doneEditDelegate)
        case IMGLYMainMenuButtonType.contrast:
            return contrastEditorViewControllerWithFixedFilterStack(fixedFilterStack, doneEditDelegate)
        case IMGLYMainMenuButtonType.saturation:
            return saturationEditorViewControllerWithFixedFilterStack(fixedFilterStack, doneEditDelegate)
        case IMGLYMainMenuButtonType.text:
            return textEditorViewControllerWithFixedFilterStack(fixedFilterStack, doneEditDelegate)
        case IMGLYMainMenuButtonType.drawer:
            return drawImageViewControllerWithFixedFilterStack(fixedFilterStack, and: (frame ?? nil)!, doneEditDelegate)
        default:
            return nil
        }
    }
    
    public class func filterEditorViewControllerWithFixedFilterStack(_ fixedFilterStack: IMGLYFixedFilterStack, _ photoEditorDelegate: DoneEditDelegate?) -> IMGLYFilterEditorViewController {
        return IMGLYFilterEditorViewController(fixedFilterStack: fixedFilterStack, photoEditorDelegate: photoEditorDelegate)
    }
    
    public class func stickersEditorViewControllerWithFixedFilterStack(_ fixedFilterStack: IMGLYFixedFilterStack, _ photoEditorDelegate: DoneEditDelegate?) -> IMGLYStickersEditorViewController {
        return IMGLYStickersEditorViewController(fixedFilterStack: fixedFilterStack, photoEditorDelegate: photoEditorDelegate)
    }
    
    public class func orientationEditorViewControllerWithFixedFilterStack(_ fixedFilterStack: IMGLYFixedFilterStack, _ photoEditorDelegate: DoneEditDelegate?) -> IMGLYOrientationEditorViewController {
        return IMGLYOrientationEditorViewController(fixedFilterStack: fixedFilterStack, photoEditorDelegate: photoEditorDelegate)
    }
    
    public class func focusEditorViewControllerWithFixedFilterStack(_ fixedFilterStack: IMGLYFixedFilterStack, _ photoEditorDelegate: DoneEditDelegate?) -> IMGLYFocusEditorViewController {
        return IMGLYFocusEditorViewController(fixedFilterStack: fixedFilterStack, photoEditorDelegate: photoEditorDelegate)
    }
    
    public class func cropEditorViewControllerWithFixedFilterStack(_ fixedFilterStack: IMGLYFixedFilterStack, _ photoEditorDelegate: DoneEditDelegate?) -> IMGLYCropEditorViewController {
        return IMGLYCropEditorViewController(fixedFilterStack: fixedFilterStack, photoEditorDelegate: photoEditorDelegate)
    }
    
    public class func brightnessEditorViewControllerWithFixedFilterStack(_ fixedFilterStack: IMGLYFixedFilterStack,  _ photoEditorDelegate: DoneEditDelegate?) -> IMGLYBrightnessEditorViewController {
        return IMGLYBrightnessEditorViewController(fixedFilterStack: fixedFilterStack, photoEditorDelegate: photoEditorDelegate)
    }
    
    public class func contrastEditorViewControllerWithFixedFilterStack(_ fixedFilterStack: IMGLYFixedFilterStack, _ photoEditorDelegate: DoneEditDelegate?) -> IMGLYContrastEditorViewController {
        return IMGLYContrastEditorViewController(fixedFilterStack: fixedFilterStack, photoEditorDelegate: photoEditorDelegate)
    }
    
    public class func saturationEditorViewControllerWithFixedFilterStack(_ fixedFilterStack: IMGLYFixedFilterStack, _ photoEditorDelegate: DoneEditDelegate?) -> IMGLYSaturationEditorViewController {
        return IMGLYSaturationEditorViewController(fixedFilterStack: fixedFilterStack, photoEditorDelegate: photoEditorDelegate)
    }
    
    public class func textEditorViewControllerWithFixedFilterStack(_ fixedFilterStack: IMGLYFixedFilterStack, _ photoEditorDelegate: DoneEditDelegate?) -> IMGLYTextEditorViewController {
        return IMGLYTextEditorViewController(fixedFilterStack: fixedFilterStack, photoEditorDelegate: photoEditorDelegate)
    }

    public class func drawImageViewControllerWithFixedFilterStack(_ fixedFilterStack: IMGLYFixedFilterStack, and frame : CGRect, _ photoEditorDelegate: DoneEditDelegate?) -> IMGLYDrawerViewController {
//        let vc = IMGLYDrawerViewController(fixedFilterStack: fixedFilterStack)
        let vc = IMGLYDrawerViewController(fixedFilterStack: fixedFilterStack, frame: frame, photoEditorDelegate: photoEditorDelegate)
        return vc
    }
    
    // MARK: - Gradient Views
    
    public class func circleGradientView() -> IMGLYCircleGradientView {
        return IMGLYCircleGradientView(frame: CGRect.zero)
    }
    
    public class func boxGradientView() -> IMGLYBoxGradientView {
        return IMGLYBoxGradientView(frame: CGRect.zero)
    }
    
    // MARK: - Helpers
    
    public class func cropRectComponent() -> IMGLYCropRectComponent {
        return IMGLYCropRectComponent()
    }
}
