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
    public class func viewControllerForButtonType(_ type: IMGLYMainMenuButtonType, withFixedFilterStack fixedFilterStack: IMGLYFixedFilterStack, and frame: CGRect? = nil, doneEdit: PhotoEditor?) -> IMGLYSubEditorViewController? {
        switch (type) {
        case IMGLYMainMenuButtonType.filter:
            return filterEditorViewControllerWithFixedFilterStack(fixedFilterStack, doneEdit)
        case IMGLYMainMenuButtonType.stickers:
            return stickersEditorViewControllerWithFixedFilterStack(fixedFilterStack, doneEdit)
        case IMGLYMainMenuButtonType.orientation:
            return orientationEditorViewControllerWithFixedFilterStack(fixedFilterStack, doneEdit)
        case IMGLYMainMenuButtonType.focus:
            return focusEditorViewControllerWithFixedFilterStack(fixedFilterStack, doneEdit)
        case IMGLYMainMenuButtonType.crop:
            return cropEditorViewControllerWithFixedFilterStack(fixedFilterStack, doneEdit)
        case IMGLYMainMenuButtonType.brightness:
            return brightnessEditorViewControllerWithFixedFilterStack(fixedFilterStack, doneEdit)
        case IMGLYMainMenuButtonType.contrast:
            return contrastEditorViewControllerWithFixedFilterStack(fixedFilterStack, doneEdit)
        case IMGLYMainMenuButtonType.saturation:
            return saturationEditorViewControllerWithFixedFilterStack(fixedFilterStack, doneEdit)
        case IMGLYMainMenuButtonType.text:
            return textEditorViewControllerWithFixedFilterStack(fixedFilterStack, doneEdit)
        case IMGLYMainMenuButtonType.drawer:
            return drawImageViewControllerWithFixedFilterStack(fixedFilterStack, and: (frame ?? nil)!, doneEdit)
        default:
            return nil
        }
    }
    
    public class func filterEditorViewControllerWithFixedFilterStack(_ fixedFilterStack: IMGLYFixedFilterStack, _ photoEdit: PhotoEditor?) -> IMGLYFilterEditorViewController {
        return IMGLYFilterEditorViewController(fixedFilterStack: fixedFilterStack, photoEdit)
    }
    
    public class func stickersEditorViewControllerWithFixedFilterStack(_ fixedFilterStack: IMGLYFixedFilterStack, _ photoEdit: PhotoEditor?) -> IMGLYStickersEditorViewController {
        return IMGLYStickersEditorViewController(fixedFilterStack: fixedFilterStack, photoEdit)
    }
    
    public class func orientationEditorViewControllerWithFixedFilterStack(_ fixedFilterStack: IMGLYFixedFilterStack, _ photoEdit: PhotoEditor?) -> IMGLYOrientationEditorViewController {
        return IMGLYOrientationEditorViewController(fixedFilterStack: fixedFilterStack, photoEdit)
    }
    
    public class func focusEditorViewControllerWithFixedFilterStack(_ fixedFilterStack: IMGLYFixedFilterStack,_ photoEdit: PhotoEditor?) -> IMGLYFocusEditorViewController {
        return IMGLYFocusEditorViewController(fixedFilterStack: fixedFilterStack,  photoEdit)
    }
    
    public class func cropEditorViewControllerWithFixedFilterStack(_ fixedFilterStack: IMGLYFixedFilterStack,_ photoEdit: PhotoEditor?) -> IMGLYCropEditorViewController {
        return IMGLYCropEditorViewController(fixedFilterStack: fixedFilterStack,  photoEdit)
    }
    
    public class func brightnessEditorViewControllerWithFixedFilterStack(_ fixedFilterStack: IMGLYFixedFilterStack,_ photoEdit: PhotoEditor?) -> IMGLYBrightnessEditorViewController {
        return IMGLYBrightnessEditorViewController(fixedFilterStack: fixedFilterStack,  photoEdit)
    }
    
    public class func contrastEditorViewControllerWithFixedFilterStack(_ fixedFilterStack: IMGLYFixedFilterStack,_ photoEdit: PhotoEditor?) -> IMGLYContrastEditorViewController {
        return IMGLYContrastEditorViewController(fixedFilterStack: fixedFilterStack,  photoEdit)
    }
    
    public class func saturationEditorViewControllerWithFixedFilterStack(_ fixedFilterStack: IMGLYFixedFilterStack,_ photoEdit: PhotoEditor?) -> IMGLYSaturationEditorViewController {
        return IMGLYSaturationEditorViewController(fixedFilterStack: fixedFilterStack,  photoEdit)
    }
    
    public class func textEditorViewControllerWithFixedFilterStack(_ fixedFilterStack: IMGLYFixedFilterStack,_ photoEdit: PhotoEditor?) -> IMGLYTextEditorViewController {
        return IMGLYTextEditorViewController(fixedFilterStack: fixedFilterStack,  photoEdit)
    }

    public class func drawImageViewControllerWithFixedFilterStack(_ fixedFilterStack: IMGLYFixedFilterStack, and frame : CGRect,_ photoEdit: PhotoEditor?) -> IMGLYDrawerViewController {
//        let vc = IMGLYDrawerViewController(fixedFilterStack: fixedFilterStack)
        let vc = IMGLYDrawerViewController(fixedFilterStack: fixedFilterStack, frame: frame,  photoEdit)
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
