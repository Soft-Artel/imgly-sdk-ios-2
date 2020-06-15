//
//  IMGLYCameraViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 10/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos

private let ShowFilterIntensitySliderInterval = TimeInterval(2)
private let FilterSelectionViewHeight = 100
private let BottomControlSize = CGSize(width: 47, height: 47)
public typealias IMGLYCameraCompletionBlock = (UIImage?, URL?) -> (Void)


public protocol CameraCloseDelegate: class {
    func close(photoPickerClosed: Bool)
    func present(view: UIViewController)
}

public protocol GalleryDelegate: class{
    func openGallery(complition: ((Bool) -> ())?)
}

open class IMGLYCameraViewController: UIViewController {
    
    // MARK: - Initializers
    
    public weak var delegateEditor: SaveImageDelegate?
    var cameraDelegate: CameraCloseDelegate? = nil
    
    public weak var galleryDelegate: GalleryDelegate? = nil
    
    public var comlitionSave: ((Bool) -> ())? = nil
    
    private var orientation: AVCaptureVideoOrientation = .portrait
    
    public convenience init() {
        self.init(recordingModes: [.photo, .video])
    }
    
    /// This initializer should only be used in Objective-C. It expects an NSArray of NSNumbers that wrap
    /// the integer value of IMGLYRecordingMode.
    public convenience init(recordingModes: [NSNumber]) {
        let modes = recordingModes.map { IMGLYRecordingMode(rawValue: $0.intValue) }.filter { $0 != nil }.map { $0! }
        self.init(recordingModes: modes)
    }
    
    /**
    Initializes a camera view controller.
    
    :param: recordingModes An array of recording modes that you want to support.
    
    :returns: An initialized IMGLYCameraViewController.
    
    :discussion: If you use the standard `init` method or `initWithCoder` to initialize a `IMGLYCameraViewController` object, a camera view controller with all supported recording modes is created.
    */
    public init(recordingModes: [IMGLYRecordingMode]) {
        assert(recordingModes.count > 0, "You need to set at least one recording mode.")
        self.recordingModes = recordingModes
        self.currentRecordingMode = recordingModes.first!
        self.squareMode = false
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        recordingModes = [.photo, .video]
        currentRecordingMode = recordingModes.first!
        self.squareMode = false
        super.init(coder: aDecoder)
    }
    
    // MARK: - Properties
    
    open fileprivate(set) lazy var backgroundContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    open fileprivate(set) lazy var topControlsView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        }()
    
    open fileprivate(set) lazy var cameraPreviewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
        }()
    
    open fileprivate(set) lazy var bottomControlsView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        }()
    
    open fileprivate(set) lazy var flashButton: UIButton = {
        let bundle = Bundle(for: type(of: self))
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "flash_auto", in: bundle, compatibleWith: nil), for: [])
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(IMGLYCameraViewController.changeFlash(_:)), for: .touchUpInside)
        button.isHidden = true
        return button
        }()
    
    open fileprivate(set) lazy var switchCameraButton: UIButton = {
        let bundle = Bundle(for: type(of: self))
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "cam_switch", in: bundle, compatibleWith: nil), for: [])
        button.contentHorizontalAlignment = .right
        button.addTarget(self, action: #selector(IMGLYCameraViewController.switchCamera(_:)), for: .touchUpInside)
        button.isHidden = true
        return button
        }()
    
    open fileprivate(set) lazy var cameraRollButton: UIButton = {
        let bundle = Bundle(for: type(of: self))
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "nonePreview", in: bundle, compatibleWith: nil), for: [])
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(IMGLYCameraViewController.showCameraRoll(_:)), for: .touchUpInside)
        button.isHidden = true
        return button
        }()
    
    open fileprivate(set) lazy var cancelButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Cancel".localized, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        return btn
    }()
    
    @objc func backAction(){
        self.dismiss(animated: true, completion: nil)
    }
    
    open fileprivate(set) lazy var actionButtonContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    open fileprivate(set) lazy var recordingTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        label.textColor = UIColor.white
        label.text = "00:00"
        return label
    }()
    
    open fileprivate(set) var actionButton: UIControl?
    
    open fileprivate(set) lazy var filterSelectionButton: UIButton = {
        let bundle = Bundle(for: type(of: self))
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "show_filter", in: bundle, compatibleWith: nil), for: [])
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(IMGLYCameraViewController.toggleFilters(_:)), for: .touchUpInside)
        button.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        button.isHidden = true
        return button
        }()
    
    open fileprivate(set) lazy var filterIntensitySlider: UISlider = {
        let bundle = Bundle(for: type(of: self))
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0.75
        slider.alpha = 0
        slider.addTarget(self, action: #selector(IMGLYCameraViewController.changeIntensity(_:)), for: .valueChanged)
        
        slider.minimumTrackTintColor = UIColor.white
        slider.maximumTrackTintColor = UIColor.white
        slider.thumbTintColor = UIColor(red:1, green:0.8, blue:0, alpha:1)
        let sliderThumbImage = UIImage(named: "slider_thumb_image", in: bundle, compatibleWith: nil)
        slider.setThumbImage(sliderThumbImage, for: [])
        slider.setThumbImage(sliderThumbImage, for: .highlighted)
        slider.isHidden = true
        return slider
    }()
    
    open fileprivate(set) lazy var swipeRightGestureRecognizer: UISwipeGestureRecognizer = {
        let recognizer = UISwipeGestureRecognizer(target: self, action: #selector(IMGLYCameraViewController.toggleMode(_:)))
        return recognizer
    }()
    
    open fileprivate(set) lazy var swipeLeftGestureRecognizer: UISwipeGestureRecognizer = {
        let recognizer = UISwipeGestureRecognizer(target: self, action: #selector(IMGLYCameraViewController.toggleMode(_:)))
        recognizer.direction = .left
        return recognizer
    }()
    
    public let recordingModes: [IMGLYRecordingMode]
    fileprivate var recordingModeSelectionButtons = [UIButton]()
    
    open fileprivate(set) var currentRecordingMode: IMGLYRecordingMode {
        didSet {
            if currentRecordingMode == oldValue {
                return
            }
            
            self.cameraController?.switchToRecordingMode(self.currentRecordingMode)
        }
    }

    open var squareMode: Bool {
        didSet {
            self.cameraController?.squareMode = false
        }
    }
    
    fileprivate var hideSliderTimer: Timer?
    
    fileprivate var filterSelectionViewConstraint: NSLayoutConstraint?
    
    open fileprivate(set) var cameraController: IMGLYCameraController?
    
    internal var defaultIsFront: Bool = false
    
    /// The maximum length of a video. If set to 0 the length is unlimited.
    open var maximumVideoLength: Int = 0 {
        didSet {
            if maximumVideoLength == 0 {
                cameraController?.maximumVideoLength = nil
            } else {
                cameraController?.maximumVideoLength = maximumVideoLength
            }
            
            updateRecordingTimeLabel(maximumVideoLength)
        }
    }
    
    fileprivate var buttonsEnabled = true {
        didSet {
            flashButton.isEnabled = true
            switchCameraButton.isEnabled =  true
            cameraRollButton.isEnabled =  true
            actionButtonContainer.isUserInteractionEnabled =  true
            
            for recordingModeSelectionButton in recordingModeSelectionButtons {
                recordingModeSelectionButton.isEnabled =  true
            }

            swipeRightGestureRecognizer.isEnabled =  true
            swipeLeftGestureRecognizer.isEnabled =  true
            filterSelectionButton.isEnabled =  true
        }
    }
    
    open var completionBlock: IMGLYCameraCompletionBlock?
    
    fileprivate var centerModeButtonConstraint: NSLayoutConstraint?
    fileprivate var cameraPreviewPhoto: NSLayoutConstraint?
    fileprivate var cameraPreviewCamera: NSLayoutConstraint?
    
    // MARK: - UIViewController

    override open func viewDidLoad() {
        super.viewDidLoad()


    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                view.backgroundColor = UIColor.black
        
        configureRecordingModeSwitching()
        configureViewHierarchy()
        configureViewConstraints()
        
        configureCameraController()
        cameraController?.squareMode = squareMode
        cameraController?.switchToRecordingMode(currentRecordingMode, animated: false)
        
        cameraController?.startCamera()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraController?.stopCamera()

    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    open override var shouldAutomaticallyForwardAppearanceMethods : Bool {
        return false
    }
    
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    open override var prefersStatusBarHidden : Bool {
        return true
    }
    
    open override var shouldAutorotate : Bool {
        return false
    }
    
    open override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return .portrait
    }

    // MARK: - Configuration
    
    fileprivate func configureRecordingModeSwitching() {
        if recordingModes.count > 1 {
            view.addGestureRecognizer(swipeLeftGestureRecognizer)
            view.addGestureRecognizer(swipeRightGestureRecognizer)
            
            recordingModeSelectionButtons = recordingModes.map { $0.selectionButton }
            
            for recordingModeSelectionButton in recordingModeSelectionButtons {
                recordingModeSelectionButton.addTarget(self, action: #selector(IMGLYCameraViewController.toggleMode(_:)), for: .touchUpInside)
            }
        }
    }
    
    fileprivate func configureViewHierarchy() {
        view.addSubview(backgroundContainerView)
        self.backgroundContainerView.addSubview(cameraPreviewContainer)
        view.addSubview(topControlsView)
        view.addSubview(bottomControlsView)
        
        
        topControlsView.addSubview(flashButton)
        topControlsView.addSubview(switchCameraButton)
        
        bottomControlsView.addSubview(cameraRollButton)
        bottomControlsView.addSubview(actionButtonContainer)
        bottomControlsView.addSubview(filterSelectionButton)
        
        bottomControlsView.addSubview(self.cancelButton)
        self.cancelButton.translatesAutoresizingMaskIntoConstraints = false
        self.cancelButton.rightAnchor.constraint(equalTo: self.actionButtonContainer.leftAnchor, constant: -50).isActive = true
        self.cancelButton.centerYAnchor.constraint(equalTo: self.actionButtonContainer.centerYAnchor, constant: 0).isActive = true
        
        for recordingModeSelectionButton in recordingModeSelectionButtons {
            bottomControlsView.addSubview(recordingModeSelectionButton)
        }
        
        cameraPreviewContainer.addSubview(filterIntensitySlider)
    }
    
    fileprivate func configureViewConstraints() {
        let views: [String : AnyObject] = [
            "backgroundContainerView" : backgroundContainerView,
            "topLayoutGuide" : topLayoutGuide,
            "topControlsView" : topControlsView,
            "cameraPreviewContainer" : cameraPreviewContainer,
            "bottomControlsView" : bottomControlsView,
            "flashButton" : flashButton,
            "switchCameraButton" : switchCameraButton,
            "cameraRollButton" : cameraRollButton,
            "actionButtonContainer" : actionButtonContainer,
            "filterSelectionButton" : filterSelectionButton,
            "filterIntensitySlider" : filterIntensitySlider
        ]
        
        let metrics: [String : AnyObject] = [
            "topControlsViewHeight" : 44 as AnyObject,
            "filterSelectionViewHeight" : FilterSelectionViewHeight as AnyObject,
            "topControlMargin" : 20 as AnyObject,
            "filterIntensitySliderLeftRightMargin" : 10 as AnyObject
        ]
        
        configureSuperviewConstraintsWithMetrics(metrics, views: views)
        configureTopControlsConstraintsWithMetrics(metrics, views: views)
        configureBottomControlsConstraintsWithMetrics(metrics, views: views)
    }
    
    fileprivate func configureSuperviewConstraintsWithMetrics(_ metrics: [String : AnyObject], views: [String : AnyObject]) {
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[backgroundContainerView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundContainerView]|", options: [], metrics: nil, views: views))
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[topControlsView]|", options: [], metrics: nil, views: views))
//        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[cameraPreviewContainer]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[bottomControlsView]|", options: [], metrics: nil, views: views))
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(==filterIntensitySliderLeftRightMargin)-[filterIntensitySlider]-(==filterIntensitySliderLeftRightMargin)-|", options: [], metrics: metrics, views: views))
        
        view.addConstraint(NSLayoutConstraint(item: filterIntensitySlider, attribute: .bottom, relatedBy: .equal, toItem: bottomControlsView, attribute: .top, multiplier: 1, constant: -20))
        
        self.topControlsView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
//        cameraPreviewContainerTopConstraint = NSLayoutConstraint(item: cameraPreviewContainer, attribute: .top, relatedBy: .equal, toItem: topControlsView, attribute: .bottom, multiplier: 1, constant: 0)
//        cameraPreviewContainerBottomConstraint = NSLayoutConstraint(item: cameraPreviewContainer, attribute: .bottom, relatedBy: .equal, toItem: bottomControlsView, attribute: .top, multiplier: 1, constant: 0)
//        view.addConstraints([cameraPreviewContainerTopConstraint!, cameraPreviewContainerBottomConstraint!])
        self.cameraPreviewContainer.topAnchor.constraint(equalTo: self.backgroundContainerView.topAnchor).isActive = true
        self.cameraPreviewPhoto = self.cameraPreviewContainer.bottomAnchor.constraint(equalTo: self.bottomControlsView.topAnchor)
        self.cameraPreviewPhoto?.isActive = true
        self.cameraPreviewCamera = self.cameraPreviewContainer.bottomAnchor.constraint(equalTo: self.backgroundContainerView.bottomAnchor)
        self.cameraPreviewCamera?.isActive = false
        self.cameraPreviewContainer.leftAnchor.constraint(equalTo: self.backgroundContainerView.leftAnchor).isActive = true
        self.cameraPreviewContainer.rightAnchor.constraint(equalTo: self.backgroundContainerView.rightAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            self.bottomControlsView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        } else {
            if #available(iOS 9.0, *) {
                self.bottomControlsView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -40).isActive = true
            } else {
                // Fallback on earlier versions
            }
        }
        
    }
    
    fileprivate func configureTopControlsConstraintsWithMetrics(_ metrics: [String : AnyObject], views: [String : AnyObject]) {
//        topControlsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(==topControlMargin)-[flashButton(>=topControlMinWidth)]-(>=topControlMargin)-[switchCameraButton(>=topControlMinWidth)]-(==topControlMargin)-|", options: [], metrics: metrics, views: views))
//        topControlsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[flashButton]|", options: [], metrics: nil, views: views))
//        topControlsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[switchCameraButton]|", options: [], metrics: nil, views: views))
        
        self.flashButton.leftAnchor.constraint(equalTo: self.topControlsView.leftAnchor, constant: 20).isActive = true
        self.flashButton.centerYAnchor.constraint(equalTo: self.topControlsView.centerYAnchor).isActive = true

        self.switchCameraButton.rightAnchor.constraint(equalTo: self.topControlsView.rightAnchor, constant: -20).isActive = true
        self.switchCameraButton.centerYAnchor.constraint(equalTo: self.topControlsView.centerYAnchor).isActive = true
    }
    
    fileprivate func configureBottomControlsConstraintsWithMetrics(_ metrics: [String : AnyObject], views: [String : AnyObject]) {
        if recordingModeSelectionButtons.count > 0 {
            // Mode Buttons
            for i in 0 ..< recordingModeSelectionButtons.count - 1 {
                let leftButton = recordingModeSelectionButtons[i]
                let rightButton = recordingModeSelectionButtons[i + 1]
                
                bottomControlsView.addConstraint(NSLayoutConstraint(item: leftButton, attribute: .right, relatedBy: .equal, toItem: rightButton, attribute: .left, multiplier: 1, constant: -20))
                bottomControlsView.addConstraint(NSLayoutConstraint(item: leftButton, attribute: .lastBaseline, relatedBy: .equal, toItem: rightButton, attribute: .lastBaseline, multiplier: 1, constant: 0))
            }
            
            centerModeButtonConstraint = NSLayoutConstraint(item: recordingModeSelectionButtons[0], attribute: .centerX, relatedBy: .equal, toItem: actionButtonContainer, attribute: .centerX, multiplier: 1, constant: 0)
            bottomControlsView.addConstraint(centerModeButtonConstraint!)
            bottomControlsView.addConstraint(NSLayoutConstraint(item: recordingModeSelectionButtons[0], attribute: .bottom, relatedBy: .equal, toItem: actionButtonContainer, attribute: .top, multiplier: 1, constant: -5))
            bottomControlsView.addConstraint(NSLayoutConstraint(item: bottomControlsView, attribute: .top, relatedBy: .equal, toItem: recordingModeSelectionButtons[0], attribute: .top, multiplier: 1, constant: -5))
        } else {
            bottomControlsView.addConstraint(NSLayoutConstraint(item: bottomControlsView, attribute: .top, relatedBy: .equal, toItem: actionButtonContainer, attribute: .top, multiplier: 1, constant: -5))
        }
        
        // CameraRollButton
        cameraRollButton.addConstraint(NSLayoutConstraint(item: cameraRollButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: BottomControlSize.width))
        cameraRollButton.addConstraint(NSLayoutConstraint(item: cameraRollButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: BottomControlSize.height))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: cameraRollButton, attribute: .centerY, relatedBy: .equal, toItem: actionButtonContainer, attribute: .centerY, multiplier: 1, constant: 0))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: cameraRollButton, attribute: .left, relatedBy: .equal, toItem: bottomControlsView, attribute: .left, multiplier: 1, constant: 20))
        
        // ActionButtonContainer
        actionButtonContainer.addConstraint(NSLayoutConstraint(item: actionButtonContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 70))
        actionButtonContainer.addConstraint(NSLayoutConstraint(item: actionButtonContainer, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 70))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: actionButtonContainer, attribute: .centerX, relatedBy: .equal, toItem: bottomControlsView, attribute: .centerX, multiplier: 1, constant: 0))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: bottomControlsView, attribute: .bottom, relatedBy: .equal, toItem: actionButtonContainer, attribute: .bottom, multiplier: 1, constant: 10))
        
        // FilterSelectionButton
        filterSelectionButton.addConstraint(NSLayoutConstraint(item: filterSelectionButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: BottomControlSize.width))
        filterSelectionButton.addConstraint(NSLayoutConstraint(item: filterSelectionButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: BottomControlSize.height))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: filterSelectionButton, attribute: .centerY, relatedBy: .equal, toItem: actionButtonContainer, attribute: .centerY, multiplier: 1, constant: 0))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: bottomControlsView, attribute: .right, relatedBy: .equal, toItem: filterSelectionButton, attribute: .right, multiplier: 1, constant: 20))
    }
    
    fileprivate func configureCameraController() {
        // Needed so that the framebuffer can bind to OpenGL ES
        view.layoutIfNeeded()
        let position: AVCaptureDevice.Position = self.defaultIsFront ? .front : .back
        cameraController = IMGLYCameraController(previewView: cameraPreviewContainer, position: position)
        guard let cameraController = self.cameraController else { return  }
        cameraController.delegateImage = self.delegateEditor
        cameraController.delegate = self
        cameraController.setupWithInitialRecordingMode(currentRecordingMode, position: position)
        if maximumVideoLength > 0 {
            cameraController.maximumVideoLength = maximumVideoLength
        }
    }
    
    // MARK: - Helpers
    
    fileprivate func updateRecordingTimeLabel(_ seconds: Int) {
        self.recordingTimeLabel.text = NSString(format: "%02d:%02d", seconds / 60, seconds % 60) as String
    }
    
    fileprivate func addRecordingTimeLabel() {
        updateRecordingTimeLabel(0)
        topControlsView.addSubview(recordingTimeLabel)
        
        topControlsView.addConstraint(NSLayoutConstraint(item: recordingTimeLabel, attribute: .centerX, relatedBy: .equal, toItem: topControlsView, attribute: .centerX, multiplier: 1, constant: 0))
        topControlsView.addConstraint(NSLayoutConstraint(item: recordingTimeLabel, attribute: .centerY, relatedBy: .equal, toItem: topControlsView, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    fileprivate func updateConstraintsForRecordingMode(_ recordingMode: IMGLYRecordingMode) {
        self.cameraPreviewPhoto?.isActive = recordingMode == .photo
        self.cameraPreviewCamera?.isActive = recordingMode == .video        
    }
    
    fileprivate func updateViewsForRecordingMode(_ recordingMode: IMGLYRecordingMode) {
        let color: UIColor
        
//        switch recordingMode {
//        case .photo:
//            color = UIColor.black
//        case .video:
            color = UIColor.black.withAlphaComponent(0.3)
//        }
        
        topControlsView.backgroundColor = color
        bottomControlsView.backgroundColor = color
        
    }
    
    fileprivate func addActionButtonToContainer(_ actionButton: UIControl) {
        actionButtonContainer.addSubview(actionButton)
        actionButtonContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[actionButton]|", options: [], metrics: nil, views: [ "actionButton" : actionButton ]))
        actionButtonContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[actionButton]|", options: [], metrics: nil, views: [ "actionButton" : actionButton ]))
    }
    
    fileprivate func updateFlashButton(with mode: AVCaptureDevice.TorchMode? = nil) {
        if let cameraController = cameraController {
            let bundle = Bundle(for: type(of: self))
            let isHor = self.orientation == .portrait ? "" : self.orientation == .portraitUpsideDown ? "" : "_h"
            if currentRecordingMode == .photo {
                flashButton.isHidden = !cameraController.flashAvailable
                switch(cameraController.flashMode) {
                case .auto:
                    self.flashButton.setImage(UIImage(named: "flash_auto" + isHor, in: bundle, compatibleWith: nil), for: [])
                case .on:
                    self.flashButton.setImage(UIImage(named: "flash_on" + isHor, in: bundle, compatibleWith: nil), for: [])
                case .off:
                    self.flashButton.setImage(UIImage(named: "flash_off" + isHor, in: bundle, compatibleWith: nil), for: [])
                default:
                    break
                }
            } else if currentRecordingMode == .video {
                flashButton.isHidden = !cameraController.torchAvailable
                
                switch(mode ?? cameraController.torchMode) {
                case .auto:
                    self.flashButton.setImage(UIImage(named: "flash_auto" + isHor, in: bundle, compatibleWith: nil), for: [])
                case .on:
                    self.flashButton.setImage(UIImage(named: "flash_on" + isHor, in: bundle, compatibleWith: nil), for: [])
                case .off:
                    self.flashButton.setImage(UIImage(named: "flash_off" + isHor, in: bundle, compatibleWith: nil), for: [])
                default:
                    break
                }
            }
        } else {
            flashButton.isHidden = true
        }
    }
    
    fileprivate func resetHideSliderTimer() {
        hideSliderTimer?.invalidate()
        hideSliderTimer = Timer.scheduledTimer(timeInterval: ShowFilterIntensitySliderInterval, target: self, selector: #selector(IMGLYCameraViewController.hideFilterIntensitySlider(_:)), userInfo: nil, repeats: false)
    }
    
    fileprivate func showEditorNavigationControllerWithImage(_ image: UIImage) {
        let editorViewController = IMGLYMainEditorViewController()
        editorViewController.highResolutionImage = image
        if let cameraController = cameraController {
            editorViewController.initialFilterType = cameraController.effectFilter.filterType
            editorViewController.initialFilterIntensity = cameraController.effectFilter.inputIntensity
        }
        editorViewController.delegateEditor = self.delegateEditor
        editorViewController.completionBlock = editorCompletionBlock
        
        let navigationController = IMGLYNavigationController(rootViewController: editorViewController)
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor : UIColor.white ]
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    fileprivate func saveMovieWithMovieURLToAssets(_ movieURL: URL) {
//        guard PhotoEditor.saveToAlbum else{
//            do {
//                let data = try Data(contentsOf: movieURL)
//                self.delegateEditor?.saveVideo(with: data)
//                try FileManager.default.removeItem(at: movieURL)
//            } catch _ {
//            }
//            return
//        }
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: movieURL)
            }) { success, error in
                if let error = error {
                    DispatchQueue.main.async {
                        let bundle = Bundle(for: type(of: self))
                        
                        let alertController = UIAlertController(title: NSLocalizedString("camera-view-controller.error-saving-video.title", tableName: nil, bundle: bundle, value: "", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: NSLocalizedString("camera-view-controller.error-saving-video.cancel", tableName: nil, bundle: bundle, value: "", comment: ""), style: .cancel, handler: nil)
                        
                        alertController.addAction(cancelAction)
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                do {
                    let data = try Data(contentsOf: movieURL)
                    self.delegateEditor?.saveVideo(with: data)
                    try FileManager.default.removeItem(at: movieURL)
                    guard let camDel = self.cameraDelegate else { return }
                    camDel.close(photoPickerClosed: false)
                } catch _ {
                }
        }
    }
    
    open func setLastImageFromRollAsPreview() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        if fetchResult.lastObject != nil {
            let lastAsset: PHAsset = fetchResult.lastObject!
            PHImageManager.default().requestImage(for: lastAsset, targetSize: CGSize(width: BottomControlSize.width * 2, height: BottomControlSize.height * 2), contentMode: PHImageContentMode.aspectFill, options: PHImageRequestOptions()) { (result, info) -> Void in
                self.cameraRollButton.setImage(result, for: [])
            }
        }
    }
    
    // MARK: - Targets
    
    @objc fileprivate func toggleMode(_ sender: AnyObject?) {
        if let gestureRecognizer = sender as? UISwipeGestureRecognizer {
            if gestureRecognizer.direction == .left {
                let currentIndex = recordingModes.firstIndex(of: currentRecordingMode)
                
                if let currentIndex = currentIndex, currentIndex < recordingModes.count - 1 {
                    currentRecordingMode = recordingModes[currentIndex + 1]
                    return
                }
            } else if gestureRecognizer.direction == .right {
                let currentIndex = recordingModes.firstIndex(of: currentRecordingMode)
                
                if let currentIndex = currentIndex, currentIndex > 0 {
                    currentRecordingMode = recordingModes[currentIndex - 1]
                    return
                }
            }
        }
        
        if let button = sender as? UIButton {
            let buttonIndex = recordingModeSelectionButtons.firstIndex(of: button)
            
            if let buttonIndex = buttonIndex {
                currentRecordingMode = recordingModes[buttonIndex]
                return
            }
        }
    }
    
    @objc fileprivate func hideFilterIntensitySlider(_ timer: Timer?) {
        UIView.animate(withDuration: 0.25, animations: {
            self.filterIntensitySlider.alpha = 0
            self.hideSliderTimer = nil
        })
    }
    
    @objc open func changeFlash(_ sender: UIButton?) {
        switch(currentRecordingMode) {
        case .photo:
            cameraController?.selectNextFlashMode()
        case .video:
            cameraController?.selectNextTorchMode()
        }
    }
    
    @objc open func switchCamera(_ sender: UIButton?) {
        cameraController?.toggleCameraPosition()
    }
    
    @objc open func showCameraRoll(_ sender: UIButton?) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.mediaTypes = [String(kUTTypeImage)]
        imagePicker.allowsEditing = false
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc open func takePhoto(_ sender: UIButton?) {
        cameraController?.takePhoto { image, error in
            if error == nil {
                DispatchQueue.main.async {
                    if let completionBlock = self.completionBlock {
                        completionBlock(image, nil)
                    } else {
                        if let image = image {
                            self.showEditorNavigationControllerWithImage(image)
                        }
                    }
                }
            }
        }
    }
    
    @objc open func recordVideo(_ sender: IMGLYVideoRecordButton?) {
        if let recordVideoButton = sender {
            if recordVideoButton.recording {
                cameraController?.setupAudioInputs()
                cameraController?.startVideoRecording()
            } else {
                cameraController?.stopVideoRecording()
                self.dismiss(animated: true) {
//                    guard  let save = self.comlitionSave else { return }
//                    save(false)
//                    save(true)
                    
                }
            }
            
            if let filterSelectionViewConstraint = filterSelectionViewConstraint, filterSelectionViewConstraint.constant != 0 {
                toggleFilters(filterSelectionButton)
            }
        }
    }
    
    @objc open func toggleFilters(_ sender: UIButton?) {
        if let filterSelectionViewConstraint = self.filterSelectionViewConstraint {
            let animationDuration = TimeInterval(0.6)
            let dampingFactor = CGFloat(0.6)
            
            if filterSelectionViewConstraint.constant == 0 {
                // Expand
                
                filterSelectionViewConstraint.constant = -1 * CGFloat(FilterSelectionViewHeight)
                UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: dampingFactor, initialSpringVelocity: 0, options: [], animations: {
                    sender?.transform = CGAffineTransform.identity
                    self.view.layoutIfNeeded()
                    }, completion: { finished in
                        
                })
            } else {
                // Close
                
                filterSelectionViewConstraint.constant = 0
                UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: dampingFactor, initialSpringVelocity: 0, options: [], animations: {
                    sender?.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                    self.view.layoutIfNeeded()
                    }, completion: { finished in
                        
                })
            }
        }
    }
    
    @objc fileprivate func changeIntensity(_ sender: UISlider?) {
        if let slider = sender {
            resetHideSliderTimer()
            cameraController?.effectFilter.inputIntensity = NSNumber(value: slider.value)
        }
    }
    
    // MARK: - Completion
    
    fileprivate func editorCompletionBlock(_ result: IMGLYEditorResult, image: UIImage?) {
        if let image = image, result == .done {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(IMGLYCameraViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func image(_ image: UIImage, didFinishSavingWithError: NSError, contextInfo:UnsafeRawPointer) {
        setLastImageFromRollAsPreview()
    }

}

extension IMGLYCameraViewController: IMGLYCameraControllerDelegate {
    public func changeOrientation(orientation: AVCaptureVideoOrientation) {
        self.orientation = orientation
        let pi = CGFloat.pi / 2
        let rotationAngle = orientation == .landscapeLeft ? -pi : orientation == .landscapeRight ? pi : 0
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.flashButton.transform = CGAffineTransform(rotationAngle: rotationAngle)
                self.updateFlashButton()
                self.switchCameraButton.transform = CGAffineTransform(rotationAngle: rotationAngle)
            }
        }
    }
    
    public func cameraControllerDidStartCamera(_ cameraController: IMGLYCameraController) {
        DispatchQueue.main.async {
            self.buttonsEnabled = true
        }
    }
    
    public func cameraControllerDidStopCamera(_ cameraController: IMGLYCameraController) {
        DispatchQueue.main.async {
            self.buttonsEnabled = false
        }
    }
    
    public func cameraControllerDidStartStillImageCapture(_ cameraController: IMGLYCameraController) {
        DispatchQueue.main.async {
            // Animate the actionButton if it is a UIButton and has a sequence of images set
            (self.actionButtonContainer.subviews.first as? UIButton)?.imageView?.startAnimating()
            self.buttonsEnabled = false
        }
    }
    
    public func cameraControllerDidFailAuthorization(_ cameraController: IMGLYCameraController) {
        DispatchQueue.main.async {
            let bundle = Bundle(for: type(of: self))

            let alertController = UIAlertController(title: NSLocalizedString("camera-view-controller.camera-no-permission.title", tableName: nil, bundle: bundle, value: "", comment: ""), message: NSLocalizedString("camera-view-controller.camera-no-permission.message", tableName: nil, bundle: bundle, value: "", comment: ""), preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: NSLocalizedString("camera-view-controller.camera-no-permission.settings", tableName: nil, bundle: bundle, value: "", comment: ""), style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.openURL(url)
                }
            }
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("camera-view-controller.camera-no-permission.cancel", tableName: nil, bundle: bundle, value: "", comment: ""), style: .cancel, handler: nil)
            
            alertController.addAction(settingsAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    public func cameraController(_ cameraController: IMGLYCameraController, didChangeToFlashMode flashMode: AVCaptureDevice.FlashMode) {
        DispatchQueue.main.async {
            self.updateFlashButton()
        }
    }
    
    public func cameraController(_ cameraController: IMGLYCameraController, didChangeToTorchMode torchMode: AVCaptureDevice.TorchMode) {
        DispatchQueue.main.async {
            self.updateFlashButton(with: torchMode)
        }
    }
    
    public func cameraControllerDidCompleteSetup(_ cameraController: IMGLYCameraController) {
        DispatchQueue.main.async {
            self.updateFlashButton()
            self.switchCameraButton.isHidden = !cameraController.moreThanOneCameraPresent
        }
    }
    
    public func cameraController(_ cameraController: IMGLYCameraController, willSwitchToCameraPosition cameraPosition: AVCaptureDevice.Position) {
        DispatchQueue.main.async {
            self.buttonsEnabled = false
        }
    }
    
    public func cameraController(_ cameraController: IMGLYCameraController, didSwitchToCameraPosition cameraPosition: AVCaptureDevice.Position) {
        DispatchQueue.main.async {
            self.buttonsEnabled = true
            self.updateFlashButton()
        }
    }
    
    public func cameraController(_ cameraController: IMGLYCameraController, willSwitchToRecordingMode recordingMode: IMGLYRecordingMode) {
        buttonsEnabled = false
        
        if let centerModeButtonConstraint = centerModeButtonConstraint {
            bottomControlsView.removeConstraint(centerModeButtonConstraint)
        }
        
        // add new action button to container
        let actionButton = currentRecordingMode.actionButton
        actionButton.addTarget(self, action: currentRecordingMode.actionSelector, for: .touchUpInside)
        actionButton.alpha = 0
        self.addActionButtonToContainer(actionButton)
        actionButton.layoutIfNeeded()
        
        let buttonIndex = recordingModes.firstIndex(of: currentRecordingMode)!
        if recordingModeSelectionButtons.count >= buttonIndex + 1 {
            let target = recordingModeSelectionButtons[buttonIndex]
            
            // create new centerModeButtonConstraint
            self.centerModeButtonConstraint = NSLayoutConstraint(item: target, attribute: .centerX, relatedBy: .equal, toItem: actionButtonContainer, attribute: .centerX, multiplier: 1, constant: 0)
            self.bottomControlsView.addConstraint(centerModeButtonConstraint!)
        }
        
        // add recordingTimeLabel
        if recordingMode == .video {
            self.addRecordingTimeLabel()
            self.cameraController?.hideSquareMask()
        } else {
            if self.squareMode {
//                self.cameraController?.showSquareMask()
            }
        }
        
    }
    
    public func cameraController(_ cameraController: IMGLYCameraController, didSwitchToRecordingMode recordingMode: IMGLYRecordingMode) {
        DispatchQueue.main.async {
            self.setLastImageFromRollAsPreview()
            self.buttonsEnabled = true
            
            if recordingMode == .photo {
                self.recordingTimeLabel.removeFromSuperview()
            }
        }
    }
    
    public func cameraControllerAnimateAlongsideFirstPhaseOfRecordingModeSwitchBlock(_ cameraController: IMGLYCameraController) -> (() -> Void) {
        return {
            let buttonIndex = self.recordingModes.firstIndex(of: self.currentRecordingMode)!
            if self.recordingModeSelectionButtons.count >= buttonIndex + 1 {
                let target = self.recordingModeSelectionButtons[buttonIndex]
                
                // mark target as selected
                target.isSelected = true
                
                // deselect all other buttons
                for recordingModeSelectionButton in self.recordingModeSelectionButtons {
                    if recordingModeSelectionButton != target {
                        recordingModeSelectionButton.isSelected = false
                    }
                }
            }
            
            // fade new action button in and old action button out
            let actionButton = self.actionButtonContainer.subviews.last as? UIControl
            
            // fetch previous action button from container
            let previousActionButton = self.actionButtonContainer.subviews.first as? UIControl
            actionButton?.alpha = 1
            
            if let previousActionButton = previousActionButton, let actionButton = actionButton, previousActionButton != actionButton {
                previousActionButton.alpha = 0
            }
            
            self.cameraRollButton.alpha = self.currentRecordingMode == .video ? 0 : 1
            
            self.bottomControlsView.layoutIfNeeded()
        }
    }
    
    public func cameraControllerFirstPhaseOfRecordingModeSwitchAnimationCompletionBlock(_ cameraController: IMGLYCameraController) -> (() -> Void) {
        return {
            if self.actionButtonContainer.subviews.count > 1 {
                // fetch previous action button from container
                let previousActionButton = self.actionButtonContainer.subviews.first as? UIControl
                
                // remove old action button
                previousActionButton?.removeFromSuperview()
            }
            
            self.updateConstraintsForRecordingMode(self.currentRecordingMode)
        }
    }
    
    public func cameraControllerAnimateAlongsideSecondPhaseOfRecordingModeSwitchBlock(_ cameraController: IMGLYCameraController) -> (() -> Void) {
        return {
            // update constraints for view hierarchy
            self.updateViewsForRecordingMode(self.currentRecordingMode)
            
            self.recordingTimeLabel.alpha = self.currentRecordingMode == .video ? 1 : 0
        }
    }
    
    public func cameraControllerDidStartRecording(_ cameraController: IMGLYCameraController) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, animations: {
                self.swipeLeftGestureRecognizer.isEnabled = false
                self.swipeRightGestureRecognizer.isEnabled = false
                
                self.switchCameraButton.alpha = 0
                self.filterSelectionButton.alpha = 0
                self.bottomControlsView.backgroundColor = UIColor.clear
                
                for recordingModeSelectionButton in self.recordingModeSelectionButtons {
                    recordingModeSelectionButton.alpha = 0
                }
            })
        }
    }
    
    fileprivate func updateUIForStoppedRecording() {
        UIView.animate(withDuration: 0.25, animations: {
            self.swipeLeftGestureRecognizer.isEnabled = true
            self.swipeRightGestureRecognizer.isEnabled = true
            
            self.switchCameraButton.alpha = 1
            self.filterSelectionButton.alpha = 1
            self.bottomControlsView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            
            self.updateRecordingTimeLabel(self.maximumVideoLength)
            
            for recordingModeSelectionButton in self.recordingModeSelectionButtons {
                recordingModeSelectionButton.alpha = 1
            }
            
            if let actionButton = self.actionButtonContainer.subviews.first as? IMGLYVideoRecordButton {
                actionButton.recording = false
            }
        })
    }
    
    public func cameraControllerDidFailRecording(_ cameraController: IMGLYCameraController, error: NSError?) {
        DispatchQueue.main.async {
            self.updateUIForStoppedRecording()
            
            let alertController = UIAlertController(title: "Error", message: "Video recording failed", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    public func cameraControllerDidFinishRecording(_ cameraController: IMGLYCameraController, fileURL: URL) {
        DispatchQueue.main.async {
            self.updateUIForStoppedRecording()
//            if let completionBlock = self.completionBlock {
//                completionBlock(nil, fileURL)
//            } else {
                self.saveMovieWithMovieURLToAssets(fileURL)
//            }
        }
    }
    
    public func cameraController(_ cameraController: IMGLYCameraController, recordedSeconds seconds: Int) {
        let displayedSeconds: Int
        
        if maximumVideoLength > 0 {
            displayedSeconds = 0 + seconds
        } else {
            displayedSeconds = seconds
        }
        
        DispatchQueue.main.async {
            self.updateRecordingTimeLabel(displayedSeconds)
        }
    }
}

extension IMGLYCameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
        
        self.dismiss(animated: true, completion: {
            if let completionBlock = self.completionBlock {
                completionBlock(image, nil)
            } else {
                if let image = image {
                    self.showEditorNavigationControllerWithImage(image)
                }
            }
        })
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}

extension IMGLYCameraViewController: CameraCloseDelegate{
    public func close(photoPickerClosed: Bool) {
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                guard  let complition = self.comlitionSave else { return }
                if let gallery = self.galleryDelegate{
                    gallery.openGallery(complition: complition)
                }else{
                    complition(photoPickerClosed)
                }
                
            }
        }
    }
    public func present(view: UIViewController) {
        self.present(view, animated: true, completion: nil)
    }
}
