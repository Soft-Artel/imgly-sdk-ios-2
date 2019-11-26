//
//  IMGLYCameraViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 10/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import Photos

let InitialFilterIntensity = Float(0.75)
private let ShowFilterIntensitySliderInterval = TimeInterval(2)
private let FilterSelectionViewHeight = 100
private let BottomControlSize = CGSize(width: 47, height: 47)
public typealias IMGLYCameraCompletionBlock = (UIImage?, URL?) -> (Void)

open class IMGLYCameraViewController: UIViewController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        let btn = UIButton(frame: CGRect(x: 100, y: 100, width: 50, height: 50))
        self.view.addSubview(btn)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(takePhoto(_:)), for: .allEvents)
    }


    fileprivate func showEditorNavigationControllerWithImage(_ image: UIImage = UIImage(named: "testingImage")!) {
//        let editorViewController = IMGLYMainEditorViewController()
//        editorViewController.highResolutionImage = image
//        if let cameraController = cameraController {
//            editorViewController.initialFilterType = cameraController.effectFilter.filterType
//            editorViewController.initialFilterIntensity = cameraController.effectFilter.inputIntensity
//        }
//        editorViewController.completionBlock = editorCompletionBlock
//
//        let navigationController = IMGLYNavigationController(rootViewController: editorViewController)
//        navigationController.navigationBar.barStyle = .black
//        navigationController.navigationBar.isTranslucent = false
//        navigationController.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor : UIColor.white ]
//        navigationController.modalPresentationStyle = .overFullScreen
//
//        self.present(navigationController, animated: true, completion: nil)
        IMGLYMainEditorViewController.showEditor(image: image, parent: self)
    }

    @objc open func takePhoto(_ sender: UIButton?) {
        self.showEditorNavigationControllerWithImage()
    }
    

}



