//
//  IMGLYEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 07/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

internal let PhotoProcessorQueue = DispatchQueue(label: "ly.img.SDK.PhotoProcessor", attributes: [])

open class IMGLYEditorViewController: UIViewController {
    
    // MARK: - Properties

    open var shouldShowActivityIndicator = true
    public var animateSeque: Bool = false
    weak var cameraDelegate: CameraCloseDelegate? = nil
    
    static var isMagic: Bool = false
    
    open var updating = false {
        didSet {
            if shouldShowActivityIndicator {
                DispatchQueue.main.async {
                    if self.updating {
                        self.activityIndicatorView.startAnimating()
                    } else {
                        self.activityIndicatorView.stopAnimating()
                    }
                }
            }
        }
    }

    open var lowResolutionImage: UIImage?
    
    open fileprivate(set) lazy var previewImageView: IMGLYZoomingImageView = {
        let imageView = IMGLYZoomingImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = self.enableZoomingInPreviewImage
        return imageView
        }()
    
    open fileprivate(set) lazy var bottomContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - UIViewController
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        configureNavigationItems()
        configureViewHierarchy()
        configureViewConstraints()
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
    
    fileprivate func configureNavigationItems() {
//        if self.animateSeque{
//            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(IMGLYEditorViewController.tappedDone(_:)))
//        }else{
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(IMGLYEditorViewController.tappedDone(_:)))
//        }
    }
    
    fileprivate func configureViewHierarchy() {
        view.backgroundColor = UIColor.black

        view.addSubview(previewImageView)
        view.addSubview(bottomContainerView)
        previewImageView.addSubview(activityIndicatorView)
    }
    
    fileprivate func configureViewConstraints() {

        let bottomAnchorConstraint: NSLayoutYAxisAnchor
        if #available(iOS 11.0, *){
            bottomAnchorConstraint = self.view.safeAreaLayoutGuide.bottomAnchor
        }else{
            bottomAnchorConstraint = self.view.bottomAnchor
        }

        self.previewImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.previewImageView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        self.previewImageView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.previewImageView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.previewImageView.bottomAnchor.constraint(equalTo: self.bottomContainerView.topAnchor).isActive = true

        self.bottomContainerView.heightAnchor.constraint(equalToConstant: 130).isActive = true
        self.bottomContainerView.bottomAnchor.constraint(equalTo: bottomAnchorConstraint).isActive = true
        self.bottomContainerView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.bottomContainerView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true

    }
    
    open var enableZoomingInPreviewImage: Bool {
        // Subclasses should override this to enable zooming
        return false
    }
    
    // MARK: - Actions
    
    @objc open func tappedDone(_ sender: UIBarButtonItem?) {
        
    }
    
    @objc open func tappedCancel(){
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
}
