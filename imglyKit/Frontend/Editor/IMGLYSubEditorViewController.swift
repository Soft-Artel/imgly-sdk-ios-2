//
//  IMGLYSubEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 08/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public typealias IMGLYSubEditorCompletionBlock = (UIImage?, IMGLYFixedFilterStack) -> (Void)
public typealias IMGLYPreviewImageGenerationCompletionBlock = () -> (Void)

open class IMGLYSubEditorViewController: IMGLYEditorViewController {
    
    // MARK: - Properties

    public let imageFrame: CGRect?
    public let fixedFilterStack: IMGLYFixedFilterStack
    open var completionHandler: IMGLYSubEditorCompletionBlock?
    
    // MARK: - Initializers
    
    public init(fixedFilterStack: IMGLYFixedFilterStack, frame: CGRect? = nil) {
        self.fixedFilterStack = fixedFilterStack.copy() as! IMGLYFixedFilterStack
        self.imageFrame = frame
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - EditorViewController
    
    open override func tappedDone(_ sender: UIBarButtonItem?) {
        completionHandler?(previewImageView.image, fixedFilterStack)

        guard let processedImage = IMGLYPhotoProcessor.processWithUIImage(lowResolutionImage!, filters: self.fixedFilterStack.activeFilters) else { return }
        self.dismiss(animated: false, completion: {
            IMGLYMainEditorViewController.showEditor(image: processedImage, parent: IMGLYMainEditorViewController.parentVC!, animate: false)
        })

    }
    
    // MARK: - Helpers
    
    open func updatePreviewImageWithCompletion(_ completionHandler: IMGLYPreviewImageGenerationCompletionBlock?) {
        if let lowResolutionImage = self.lowResolutionImage {
            updating = true
            PhotoProcessorQueue.async {
                let processedImage = IMGLYPhotoProcessor.processWithUIImage(lowResolutionImage, filters: self.fixedFilterStack.activeFilters)
                
                DispatchQueue.main.async {
                    self.previewImageView.image = processedImage
                    self.updating = false
                    completionHandler?()
                }
            }
        }
    }
    
    internal func updatePreviewImage() {
        updatePreviewImageWithCompletion(nil)
    }
}
