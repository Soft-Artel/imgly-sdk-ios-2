//
//  IMGLYOrientationEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 13/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

open class IMGLYOrientationEditorViewController: IMGLYSubEditorViewController {
    
    public var doneBtn = UIButton()
    public var cancelBtn = UIButton()
    // MARK: - Properties
    
    open fileprivate(set) lazy var rotateLeftButton: UIButton = {
        let bundle = Bundle(for: type(of: self))
        let button = UIButton()//= UIButton()
        let image = UIImage(named: "icon_orientation_rotate-l", in: bundle, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(IMGLYOrientationEditorViewController.rotateLeft(_:)), for: .touchUpInside)
        return button
    }()
    
    open fileprivate(set) lazy var rotateRightButton: UIButton = {
        let bundle = Bundle(for: type(of: self))
//        let button = UIButton()
        let button = UIButton()//= UIButton()
        let image = UIImage(named: "icon_orientation_rotate-r", in: bundle, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(IMGLYOrientationEditorViewController.rotateRight(_:)), for: .touchUpInside)
        return button
    }()
    
    open fileprivate(set) lazy var flipHorizontallyButton: UIButton = {
        let bundle = Bundle(for: type(of: self))
//        let button = UIButton()
        let button = UIButton()//= UIButton()
        let image = UIImage(named: "icon_orientation_flip-h", in: bundle, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(IMGLYOrientationEditorViewController.flipHorizontally(_:)), for: .touchUpInside)
        return button
    }()
    
    open fileprivate(set) lazy var flipVerticallyButton: UIButton = {
        let bundle = Bundle(for: type(of: self))
        let button = UIButton()//= UIButton()
        let image = UIImage(named: "icon_orientation_flip-v", in: bundle, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(IMGLYOrientationEditorViewController.flipVertically(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var transparentRectView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    fileprivate let cropRectComponent = IMGLYInstanceFactory.cropRectComponent()
    fileprivate var cropRectLeftBound = CGFloat(0)
    fileprivate var cropRectRightBound = CGFloat(0)
    fileprivate var cropRectTopBound = CGFloat(0)
    fileprivate var cropRectBottomBound = CGFloat(0)
    
    // MARK: - UIViewController
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = Bundle(for: type(of: self))
        navigationItem.title = NSLocalizedString("orientation-editor.title", tableName: nil, bundle: bundle, value: "", comment: "")
        
        configureButtons()
        configureCropRect()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let cropRect = fixedFilterStack.orientationCropFilter.cropRect
        if cropRect.origin.x != 0 || cropRect.origin.y != 0 ||
            cropRect.size.width != 1.0 || cropRect.size.height != 1.0 {
            updatePreviewImageWithoutCropWithCompletion {
                self.view.layoutIfNeeded()
                self.cropRectComponent.present(self.view.bounds)
                self.layoutCropRectViews()
            }
        } else {
            layoutCropRectViews()
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.transparentRectView.frame.size = self.previewImageView.visibleImageFrame.size
        self.transparentRectView.frame = self.previewImageView.visibleImageFrame
        self.transparentRectView.center.y = self.bottomContainerView.frame.origin.y / 2
        self.transparentRectView.center.x = self.previewImageView.center.x
        self.reCalculateCropRectBounds()
    }
    
    // MARK: - IMGLYEditorViewController
    
    open override var enableZoomingInPreviewImage: Bool {
        return true
    }
    
    // MARK: - SubEditorViewController
    
    open override func tappedDone(_ sender: UIBarButtonItem?) {
        updatePreviewImageWithCompletion {
            super.tappedDone(sender)
        }
    }
    
    // MARK: - Configuration
    
    fileprivate func configureButtons() {
        let buttonContainerView = UIStackView()
        buttonContainerView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.addSubview(buttonContainerView)
        
        buttonContainerView.addArrangedSubview(self.cancelBtn)
        buttonContainerView.addArrangedSubview(self.rotateLeftButton)
        buttonContainerView.addArrangedSubview(self.rotateRightButton)
        buttonContainerView.addArrangedSubview(self.flipHorizontallyButton)
        buttonContainerView.addArrangedSubview(self.flipVerticallyButton)
        buttonContainerView.addArrangedSubview(self.doneBtn)
        
        
        buttonContainerView.axis = .horizontal
        buttonContainerView.alignment = .center
        buttonContainerView.distribution = .fillEqually
        
        buttonContainerView.topAnchor.constraint(equalTo: self.bottomContainerView.topAnchor).isActive = true
        buttonContainerView.bottomAnchor.constraint(equalTo: self.bottomContainerView.bottomAnchor).isActive = true
        buttonContainerView.rightAnchor.constraint(equalTo: self.bottomContainerView.rightAnchor).isActive = true
        buttonContainerView.leftAnchor.constraint(equalTo: self.bottomContainerView.leftAnchor).isActive = true
        
        let bundle = Bundle(for: type(of: self))
        
        self.cancelBtn.setImage(UIImage(named: "cancel", in: bundle, compatibleWith: nil), for: [])
        self.doneBtn.setImage(UIImage(named: "done", in: bundle, compatibleWith: nil), for: [])
        
        self.doneBtn.addTarget(self, action: #selector(self.tappedDone(_:)), for: .touchUpInside)
        self.cancelBtn.addTarget(self, action: #selector(self.tappedCancel), for: .touchUpInside)
        
    }
    
    fileprivate func configureCropRect() {
        view.addSubview(transparentRectView)
        cropRectComponent.cropRect = fixedFilterStack.orientationCropFilter.cropRect
        cropRectComponent.setup(transparentRectView, parentView: self.view, showAnchors: false)
    }
    
    // MARK: - Helpers
    
    fileprivate func updatePreviewImageWithoutCropWithCompletion(_ completionHandler: IMGLYPreviewImageGenerationCompletionBlock?) {
        let oldCropRect = fixedFilterStack.orientationCropFilter.cropRect
        fixedFilterStack.orientationCropFilter.cropRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        updatePreviewImageWithCompletion { () -> (Void) in
            self.fixedFilterStack.orientationCropFilter.cropRect = oldCropRect
            completionHandler?()
        }
    }
    
    // MARK: - Cropping
    
    fileprivate func layoutCropRectViews() {
        reCalculateCropRectBounds()
        let viewWidth = cropRectRightBound - cropRectLeftBound
        let viewHeight = cropRectBottomBound - cropRectTopBound
        let x = cropRectLeftBound + viewWidth * fixedFilterStack.orientationCropFilter.cropRect.origin.x
        let y = cropRectTopBound + viewHeight * fixedFilterStack.orientationCropFilter.cropRect.origin.y
        let width = viewWidth * fixedFilterStack.orientationCropFilter.cropRect.size.width
        let height = viewHeight * fixedFilterStack.orientationCropFilter.cropRect.size.height
        let rect = CGRect(x: x, y: y, width: width, height: height)
        cropRectComponent.cropRect = rect
        cropRectComponent.layoutViewsForCropRect(self.transparentRectView.bounds)
    }
    
    fileprivate func reCalculateCropRectBounds() {
        let width = transparentRectView.frame.size.width
        let height = transparentRectView.frame.size.height
        cropRectLeftBound = (width - previewImageView.visibleImageFrame.size.width) / 2.0
        cropRectRightBound = width - cropRectLeftBound
        cropRectTopBound = (height - previewImageView.visibleImageFrame.size.height) / 2.0
        cropRectBottomBound = height - cropRectTopBound
    }
    
    fileprivate func rotateCropRectLeft() {
        moveCropRectMidToOrigin()
        // rotatate
        let tempRect = fixedFilterStack.orientationCropFilter.cropRect
        fixedFilterStack.orientationCropFilter.cropRect.origin.x = tempRect.origin.y
        fixedFilterStack.orientationCropFilter.cropRect.origin.y = -tempRect.origin.x
        fixedFilterStack.orientationCropFilter.cropRect.size.width = tempRect.size.height
        fixedFilterStack.orientationCropFilter.cropRect.size.height = -tempRect.size.width
        moveCropRectTopLeftToOrigin()
    }
    
    fileprivate func rotateCropRectRight() {
        moveCropRectMidToOrigin()
        // rotatate
        let tempRect = fixedFilterStack.orientationCropFilter.cropRect
        fixedFilterStack.orientationCropFilter.cropRect.origin.x = -tempRect.origin.y
        fixedFilterStack.orientationCropFilter.cropRect.origin.y = tempRect.origin.x
        fixedFilterStack.orientationCropFilter.cropRect.size.width = -tempRect.size.height
        fixedFilterStack.orientationCropFilter.cropRect.size.height = tempRect.size.width
        moveCropRectTopLeftToOrigin()
    }
    
    fileprivate func flipCropRectHorizontal() {
        moveCropRectMidToOrigin()
        fixedFilterStack.orientationCropFilter.cropRect.origin.x = -fixedFilterStack.orientationCropFilter.cropRect.origin.x - fixedFilterStack.orientationCropFilter.cropRect.size.width
        moveCropRectTopLeftToOrigin()
    }
    
    fileprivate func flipCropRectVertical() {
        moveCropRectMidToOrigin()
        fixedFilterStack.orientationCropFilter.cropRect.origin.y = -fixedFilterStack.orientationCropFilter.cropRect.origin.y - fixedFilterStack.orientationCropFilter.cropRect.size.height
        moveCropRectTopLeftToOrigin()
    }
    
    fileprivate func moveCropRectMidToOrigin() {
        fixedFilterStack.orientationCropFilter.cropRect.origin.x -= 0.5
        fixedFilterStack.orientationCropFilter.cropRect.origin.y -= 0.5
    }
    
    fileprivate func moveCropRectTopLeftToOrigin() {
        fixedFilterStack.orientationCropFilter.cropRect.origin.x += 0.5
        fixedFilterStack.orientationCropFilter.cropRect.origin.y += 0.5
    }
    
    // MARK: - Actions
    
    @objc fileprivate func rotateLeft(_ sender: UIButton) {
        fixedFilterStack.orientationCropFilter.rotateLeft()
        rotateCropRectLeft()
        updatePreviewImageWithoutCropWithCompletion {
            self.view.layoutIfNeeded()
            self.layoutCropRectViews()
        }
    }
    
    @objc fileprivate func rotateRight(_ sender: UIButton) {
        fixedFilterStack.orientationCropFilter.rotateRight()
        rotateCropRectRight()
        updatePreviewImageWithoutCropWithCompletion {
            self.view.layoutIfNeeded()
            self.layoutCropRectViews()
        }
    }
    
    @objc fileprivate func flipHorizontally(_ sender: UIButton) {
        fixedFilterStack.orientationCropFilter.flipHorizontal()
        flipCropRectHorizontal()
        updatePreviewImageWithoutCropWithCompletion {
            self.layoutCropRectViews()
        }
    }
    
    @objc fileprivate func flipVertically(_ sender: UIButton) {
        fixedFilterStack.orientationCropFilter.flipVertical()
        flipCropRectVertical()
        updatePreviewImageWithoutCropWithCompletion {
            self.layoutCropRectViews()
        }
    }
}
