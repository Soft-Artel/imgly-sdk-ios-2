//
//  IMGLYFocusEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 13/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

open class IMGLYFocusEditorViewController: IMGLYSubEditorViewController {
    
    // MARK: - Properties
    
    public var doneBtn = UIButton()
    public var cancelBtn = UIButton()
    
    open fileprivate(set) lazy var offButton: IMGLYImageCaptionButton = {
        let bundle = Bundle(for: type(of: self))
        let button = IMGLYImageCaptionButton()
        button.textLabel.text = NSLocalizedString("focus-editor.off", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_focus_off", in: bundle, compatibleWith: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(IMGLYFocusEditorViewController.turnOff(_:)), for: .touchUpInside)
        return button
    }()
    
    open fileprivate(set) lazy var linearButton: IMGLYImageCaptionButton = {
        let bundle = Bundle(for: type(of: self))
        let button = IMGLYImageCaptionButton()
        button.textLabel.text = NSLocalizedString("focus-editor.linear", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_focus_linear", in: bundle, compatibleWith: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(IMGLYFocusEditorViewController.activateLinear(_:)), for: .touchUpInside)
        return button
    }()
    
    open fileprivate(set) lazy var radialButton: IMGLYImageCaptionButton = {
        let bundle = Bundle(for: type(of: self))
        let button = IMGLYImageCaptionButton()
        button.textLabel.text = NSLocalizedString("focus-editor.radial", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_focus_radial", in: bundle, compatibleWith: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(IMGLYFocusEditorViewController.activateRadial(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate var selectedButton: IMGLYImageCaptionButton? {
        willSet(newSelectedButton) {
            self.selectedButton?.isSelected = false
        }
        
        didSet {
            self.selectedButton?.isSelected = true
        }
    }
    
    fileprivate lazy var circleGradientView: IMGLYCircleGradientView = {
        let view = IMGLYCircleGradientView()
        view.gradientViewDelegate = self
        view.isHidden = true
        view.alpha = 0
        return view
    }()
    
    fileprivate lazy var boxGradientView: IMGLYBoxGradientView = {
        let view = IMGLYBoxGradientView()
        view.gradientViewDelegate = self
        view.isHidden = true
        view.alpha = 0
        return view
    }()
    
    // MARK: - UIViewController
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = Bundle(for: type(of: self))
        navigationItem.title = NSLocalizedString("focus-editor.title", tableName: nil, bundle: bundle, value: "", comment: "")
        
        configureButtons()
        configureGradientViews()
        
        selectedButton = offButton
        if fixedFilterStack.tiltShiftFilter.tiltShiftType != .off {
            fixedFilterStack.tiltShiftFilter.tiltShiftType = .off
            updatePreviewImage()
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        circleGradientView.frame = view.convert(previewImageView.visibleImageFrame, from: previewImageView)
        circleGradientView.centerGUIElements()
        
        boxGradientView.frame = view.convert(previewImageView.visibleImageFrame, from: previewImageView)
        boxGradientView.centerGUIElements()
    }
    
    // MARK: - Configuration
    
    fileprivate func configureButtons() {
        
        let buttonContainerView = UIStackView()
        buttonContainerView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.addSubview(buttonContainerView)
        
        buttonContainerView.addArrangedSubview(self.cancelBtn)
        buttonContainerView.addArrangedSubview(offButton)
        buttonContainerView.addArrangedSubview(linearButton)
        buttonContainerView.addArrangedSubview(radialButton)
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
    
    fileprivate func configureGradientViews() {
        view.addSubview(circleGradientView)
        view.addSubview(boxGradientView)
    }
    
    // MARK: - Actions
    
    @objc fileprivate func turnOff(_ sender: IMGLYImageCaptionButton) {
        if selectedButton == sender {
            return
        }
        
        selectedButton = sender
        hideBoxGradientView()
        hideCircleGradientView()
        updateFilterTypeAndPreview()
    }
    
    @objc fileprivate func activateLinear(_ sender: IMGLYImageCaptionButton) {
        if selectedButton == sender {
            return
        }
        
        selectedButton = sender
        hideCircleGradientView()
        showBoxGradientView()
        updateFilterTypeAndPreview()
    }
    
    @objc fileprivate func activateRadial(_ sender: IMGLYImageCaptionButton) {
        if selectedButton == sender {
            return
        }
        
        selectedButton = sender
        hideBoxGradientView()
        showCircleGradientView()
        updateFilterTypeAndPreview()
    }
    
    // MARK: - Helpers
    
    fileprivate func updateFilterTypeAndPreview() {
        if selectedButton == linearButton {
            fixedFilterStack.tiltShiftFilter.tiltShiftType = .box
            fixedFilterStack.tiltShiftFilter.controlPoint1 = boxGradientView.normalizedControlPoint1
            fixedFilterStack.tiltShiftFilter.controlPoint2 = boxGradientView.normalizedControlPoint2
        } else if selectedButton == radialButton {
            fixedFilterStack.tiltShiftFilter.tiltShiftType = .circle
            fixedFilterStack.tiltShiftFilter.controlPoint1 = circleGradientView.normalizedControlPoint1
            fixedFilterStack.tiltShiftFilter.controlPoint2 = circleGradientView.normalizedControlPoint2
        } else if selectedButton == offButton {
            fixedFilterStack.tiltShiftFilter.tiltShiftType = .off
        }
        
        updatePreviewImage()
    }
    
    fileprivate func showCircleGradientView() {
        circleGradientView.isHidden = false
        UIView.animate(withDuration: TimeInterval(0.15), animations: {
            self.circleGradientView.alpha = 1.0
        })
    }
    
    fileprivate func hideCircleGradientView() {
        UIView.animate(withDuration: TimeInterval(0.15), animations: {
            self.circleGradientView.alpha = 0.0
        },
                       completion: { finished in
                        if(finished) {
                            self.circleGradientView.isHidden = true
                        }
        }
        )
    }
    
    fileprivate func showBoxGradientView() {
        boxGradientView.isHidden = false
        UIView.animate(withDuration: TimeInterval(0.15), animations: {
            self.boxGradientView.alpha = 1.0
        })
    }
    
    fileprivate func hideBoxGradientView() {
        UIView.animate(withDuration: TimeInterval(0.15), animations: {
            self.boxGradientView.alpha = 0.0
        },
                       completion: { finished in
                        if(finished) {
                            self.boxGradientView.isHidden = true
                        }
        }
        )
    }
    
}

extension IMGLYFocusEditorViewController: IMGLYGradientViewDelegate {
    public func userInteractionStarted() {
        fixedFilterStack.tiltShiftFilter.tiltShiftType = .off
        updatePreviewImage()
    }
    
    public func userInteractionEnded() {
        updateFilterTypeAndPreview()
    }
    
    public func controlPointChanged() {
        
    }
}
