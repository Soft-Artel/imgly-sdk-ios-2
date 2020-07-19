//
//  IMGLYSliderEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 10/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

open class IMGLYSliderEditorViewController: IMGLYSubEditorViewController {
    
    // MARK: - Properties
    
    public var doneBtn = UIButton()
    public var cancelBtn = UIButton()
    
    open fileprivate(set) lazy var slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = self.minimumValue
        slider.maximumValue = self.maximumValue
        slider.value = self.initialValue
        slider.isContinuous = true
        slider.addTarget(self, action: #selector(IMGLYSliderEditorViewController.sliderValueChanged(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(IMGLYSliderEditorViewController.sliderTouchedUpInside(_:)), for: .touchUpInside)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    open var minimumValue: Float {
        // Subclasses should override this
        return -1
    }
    
    open var maximumValue: Float {
        // Subclasses should override this
        return 1
    }
    
    open var initialValue: Float {
        // Subclasses should override this
        return 0
    }
    
    fileprivate var changeTimer: Timer?
    fileprivate var updateInterval: TimeInterval = 0.01
    
    // MARK: - UIViewController
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        shouldShowActivityIndicator = false
        configureViews()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem()
    }
    
    // MARK: - IMGLYEditorViewController
    
    open override var enableZoomingInPreviewImage: Bool {
        return true
    }
    
    // MARK: - Configuration
    
    fileprivate func configureViews() {
        let bundle = Bundle(for: type(of: self))
        
        self.bottomContainerView.addSubview(self.doneBtn)
        self.doneBtn.translatesAutoresizingMaskIntoConstraints = false
        self.doneBtn.rightAnchor.constraint(equalTo: self.bottomContainerView.rightAnchor, constant: -15).isActive = true
        self.doneBtn.centerYAnchor.constraint(equalTo: self.bottomContainerView.centerYAnchor).isActive = true
        self.doneBtn.heightAnchor.constraint(equalToConstant: 36).isActive = true
        self.doneBtn.widthAnchor.constraint(equalTo: self.doneBtn.heightAnchor).isActive = true
        
        self.doneBtn.setImage(UIImage(named: "done", in: bundle, compatibleWith: nil), for: [])
        
        self.bottomContainerView.addSubview(self.cancelBtn)
        self.cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        self.cancelBtn.leftAnchor.constraint(equalTo: self.bottomContainerView.leftAnchor, constant: 15).isActive = true
        self.cancelBtn.centerYAnchor.constraint(equalTo: self.bottomContainerView.centerYAnchor).isActive = true
        self.cancelBtn.heightAnchor.constraint(equalToConstant: 36).isActive = true
        self.cancelBtn.widthAnchor.constraint(equalTo: self.cancelBtn.heightAnchor).isActive = true
        
        self.cancelBtn.setImage(UIImage(named: "cancel", in: bundle, compatibleWith: nil), for: [])
        
        self.doneBtn.addTarget(self, action: #selector(self.tappedDone(_:)), for: .touchUpInside)
        self.cancelBtn.addTarget(self, action: #selector(self.tappedCancel), for: .touchUpInside)
        
        self.bottomContainerView.addSubview(slider)
        
        self.slider.centerYAnchor.constraint(equalTo: self.bottomContainerView.centerYAnchor).isActive = true
        self.slider.rightAnchor.constraint(equalTo: self.doneBtn.leftAnchor, constant: -15).isActive = true
        self.slider.leftAnchor.constraint(equalTo: self.cancelBtn.rightAnchor, constant: 15).isActive = true
        
    }
    
    // MARK: - Actions
    
    @objc fileprivate func sliderValueChanged(_ sender: UISlider?) {
        if changeTimer == nil {
            changeTimer = Timer.scheduledTimer(timeInterval: updateInterval, target: self, selector: #selector(IMGLYSliderEditorViewController.update(_:)), userInfo: nil, repeats: false)
        }
    }
    
    @objc fileprivate func sliderTouchedUpInside(_ sender: UISlider?) {
        changeTimer?.invalidate()
        
        valueChanged(slider.value)
        updatePreviewImageWithCompletion {
            self.changeTimer = nil
        }
    }
    
    @objc fileprivate func update(_ timer: Timer) {
        valueChanged(slider.value)
        updatePreviewImageWithCompletion {
            self.changeTimer = nil
        }
    }
    
    // MARK: - Subclasses
    
    open func valueChanged(_ value: Float) {
        // Subclasses should override this
    }
    
}
