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

    public var photoEditorDelegate: PhotoEditor?
    public let imageFrame: CGRect?
    public let fixedFilterStack: IMGLYFixedFilterStack
    open var completionHandler: IMGLYSubEditorCompletionBlock?
    
    // MARK: - Initializers
    
    public init(fixedFilterStack: IMGLYFixedFilterStack, frame: CGRect? = nil,_ photoEdit: PhotoEditor?) {
        self.fixedFilterStack = fixedFilterStack.copy() as! IMGLYFixedFilterStack
        self.imageFrame = frame
        self.photoEditorDelegate = photoEdit
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - EditorViewController
    
    public override func tappedDone(_ sender: UIBarButtonItem?) {
        completionHandler?(previewImageView.image, fixedFilterStack)

        guard let processedImage = IMGLYPhotoProcessor.processWithUIImage(lowResolutionImage!, filters: self.fixedFilterStack.activeFilters) else { return }

        let transition = CATransition()
        transition.duration = 0.2
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .reveal
        transition.subtype = nil
        self.view.window?.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: {
            FilterPreviews = [:]
            self.photoEditorDelegate?.close(processedImage, isMagic: IMGLYEditorViewController.isMagic)
        })
    }
    
    @objc open func tappedCancel(){
         guard let processedImage = IMGLYPhotoProcessor.processWithUIImage(lowResolutionImage!, filters: self.fixedFilterStack.activeFilters) else { return }
        
        self.dismiss(animated: false, completion: {
            FilterPreviews = [:]
            self.photoEditorDelegate?.close(processedImage, isMagic: IMGLYEditorViewController.isMagic)
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
