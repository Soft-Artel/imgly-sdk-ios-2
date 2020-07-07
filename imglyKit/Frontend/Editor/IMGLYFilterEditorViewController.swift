//
//  IMGLYFilterEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 08/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

open class IMGLYFilterEditorViewController: IMGLYSubEditorViewController {
    
    // MARK: - Properties
    
    public var doneBtn = UIButton()
    public var cancelBtn = UIButton()
    
    private var filterSelectionController: IMGLYFilterSelectionController?
    
    open fileprivate(set) lazy var filterIntensitySlider: UISlider = {
        let bundle = Bundle(for: type(of: self))
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0.75
        slider.addTarget(self, action: #selector(IMGLYFilterEditorViewController.changeIntensity(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(IMGLYFilterEditorViewController.sliderTouchedUpInside(_:)), for: .touchUpInside)
        
        slider.minimumTrackTintColor = UIColor.white
        slider.maximumTrackTintColor = UIColor.white
        let sliderThumbImage = UIImage(named: "slider_thumb_image", in: bundle, compatibleWith: nil)
        slider.setThumbImage(sliderThumbImage, for: [])
        slider.setThumbImage(sliderThumbImage, for: .highlighted)
        
        return slider
    }()
    
    fileprivate var changeTimer: Timer?
    fileprivate var updateInterval: TimeInterval = 0.01
    
    // MARK: - UIViewController
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        if self.filterSelectionController != nil{
            self.filterSelectionController = nil
        }
        
        self.filterSelectionController = IMGLYFilterSelectionController()
        let image = self.previewImageView.image
        self.filterSelectionController?.previewImage = image
        let bundle = Bundle(for: type(of: self))
        navigationItem.title = NSLocalizedString("filter-editor.title", tableName: nil, bundle: bundle, value: "", comment: "")
        
        configureFilterSelectionController()
        configureFilterIntensitySlider()
    }
    
    // MARK: - IMGLYEditorViewController
    
    open override var enableZoomingInPreviewImage: Bool {
        return true
    }
    
    // MARK: - Configuration
    
    fileprivate func configureFilterSelectionController() {
        self.filterSelectionController?.selectedBlock = { [weak self] filterType in
            if filterType == .none {
                if let filterIntensitySlider = self?.filterIntensitySlider, filterIntensitySlider.alpha > 0 {
                    UIView.animate(withDuration: 0.3, animations: {
                        filterIntensitySlider.alpha = 0
                    }) 
                }
            } else {
                if let filterIntensitySlider = self?.filterIntensitySlider, filterIntensitySlider.alpha < 1 {
                    UIView.animate(withDuration: 0.3, animations: {
                        filterIntensitySlider.alpha = 1
                    }) 
                }
            }
            
            if let fixedFilterStack = self?.fixedFilterStack, filterType != fixedFilterStack.effectFilter.filterType {
                fixedFilterStack.effectFilter = IMGLYInstanceFactory.effectFilterWithType(filterType)
                fixedFilterStack.effectFilter.inputIntensity = NSNumber(value: InitialFilterIntensity)
                self?.filterIntensitySlider.value = InitialFilterIntensity
            }
            
            self?.updatePreviewImage()
        }
        
        self.filterSelectionController?.activeFilterType = { [weak self] in
            if let fixedFilterStack = self?.fixedFilterStack {
                return fixedFilterStack.effectFilter.filterType
            }
            
            return nil
        }
        
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
        
        addChild(self.filterSelectionController!)
        self.filterSelectionController?.didMove(toParent: self)
        bottomContainerView.addSubview(self.filterSelectionController!.view)
        
        self.bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.filterSelectionController?.view.topAnchor.constraint(equalTo: self.bottomContainerView.topAnchor).isActive = true
        self.filterSelectionController?.view.bottomAnchor.constraint(equalTo: self.bottomContainerView.bottomAnchor).isActive = true
        self.filterSelectionController?.view.rightAnchor.constraint(equalTo: self.doneBtn.leftAnchor, constant: -20).isActive = true
        self.filterSelectionController?.view.leftAnchor.constraint(equalTo: self.cancelBtn.rightAnchor, constant: 20).isActive = true
        
    }
    
    fileprivate func configureFilterIntensitySlider() {
        if fixedFilterStack.effectFilter.filterType == .none {
            filterIntensitySlider.alpha = 0
        } else {
            filterIntensitySlider.value = fixedFilterStack.effectFilter.inputIntensity.floatValue
            filterIntensitySlider.alpha = 1
        }
        
        view.addSubview(filterIntensitySlider)
        
        let views: [String : AnyObject] = [
            "filterIntensitySlider" : filterIntensitySlider
        ]
        
        let metrics: [String : AnyObject] = [
            "filterIntensitySliderLeftRightMargin" : 10 as AnyObject
        ]
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(==filterIntensitySliderLeftRightMargin)-[filterIntensitySlider]-(==filterIntensitySliderLeftRightMargin)-|", options: [], metrics: metrics, views: views))
        view.addConstraint(NSLayoutConstraint(item: filterIntensitySlider, attribute: .bottom, relatedBy: .equal, toItem: previewImageView, attribute: .bottom, multiplier: 1, constant: -20))
    }
    
    // MARK: - Callbacks
    
    @objc fileprivate func changeIntensity(_ sender: UISlider?) {
        if changeTimer == nil {
            changeTimer = Timer.scheduledTimer(timeInterval: updateInterval, target: self, selector: #selector(IMGLYFilterEditorViewController.update(_:)), userInfo: nil, repeats: false)
        }
    }
    
    @objc fileprivate func sliderTouchedUpInside(_ sender: UISlider?) {
        changeTimer?.invalidate()
        
        fixedFilterStack.effectFilter.inputIntensity = NSNumber(value: filterIntensitySlider.value)
        shouldShowActivityIndicator = false
        updatePreviewImageWithCompletion {
            self.changeTimer = nil
            self.shouldShowActivityIndicator = true
        }
    }
    
    @objc fileprivate func update(_ timer: Timer) {
        fixedFilterStack.effectFilter.inputIntensity = NSNumber(value: filterIntensitySlider.value)
        shouldShowActivityIndicator = false
        updatePreviewImageWithCompletion {
            self.changeTimer = nil
            self.shouldShowActivityIndicator = true
        }
    }
    
}
