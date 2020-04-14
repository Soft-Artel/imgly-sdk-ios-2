//
//  PhtoEditor.swift
//  imglyKit iOS
//
//  Created by Мурат Камалов on 05.12.2019.
//  Copyright © 2019 9elements GmbH. All rights reserved.
//

import UIKit

let InitialFilterIntensity = Float(0.75)
private let ShowFilterIntensitySliderInterval = TimeInterval(2)
private let FilterSelectionViewHeight = 100
private let BottomControlSize = CGSize(width: 47, height: 47)

open class PhotoEditor{

    var image: UIImage?
    weak var delegateImage: SaveImageDelegate?
    let parentVC: UIViewController?
    var photoEditor: PhotoEditor? = nil
    public var complition: ((Bool) -> ())? = nil
    
    var complitionSave : (() -> ())? = nil
    
    var cameraContoler: CameraCloseDelegate? = nil
    public init(image: UIImage?, delegate: SaveImageDelegate? = nil ,parent: UIViewController?, complit: ((Bool) -> ())? = nil) {
        self.image = image
        self.delegateImage = delegate
        self.parentVC = parent
        self.complition = complit
        self.photoEditor = self
    }
    
    public init(parent: UIViewController){
        self.parentVC = parent
        self.photoEditor = self
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    public func startEditing(again: Bool = false, cameraContoler: CameraCloseDelegate? = nil){
        if self.photoEditor == nil{
            self.photoEditor = self
        }
        let editorViewController = IMGLYMainEditorViewController()
        editorViewController.delegateEditor = self.delegateImage
        editorViewController.photoPickerComplition = self.complition
        editorViewController.highResolutionImage = self.image
        editorViewController.photoEditor = self.photoEditor
        editorViewController.cameraDelegate = self.cameraContoler
        let navigationController = IMGLYNavigationController(rootViewController: editorViewController)
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor : UIColor.white ]
        navigationController.modalPresentationStyle = .overFullScreen

        if again{
            editorViewController.animateSeque = true
        }
        if cameraContoler != nil{
            self.cameraContoler = cameraContoler
            editorViewController.cameraDelegate = self.cameraContoler
            editorViewController.reopenCamera = reopen
            cameraContoler?.present(view: navigationController)
        }else{
            parentVC?.present(navigationController, animated: false, completion: nil)
        }
    }
    
    func reopen(){
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        self.parentVC?.view.addSubview(blur)
        blur.frame = self.parentVC?.view.frame as! CGRect
        cameraContoler?.close()
        
        self.openCamera(with: self.complitionSave, presentComplition: blur.removeFromSuperview)
        
    }
    
    public func openCamera(with complitionSave: (() -> ())?, presentComplition: (() -> ())? = nil){
        
        
        let cameraViewController = IMGLYCameraViewController(recordingModes: [.photo, .video])
        
        self.complitionSave = complitionSave
        cameraViewController.comlitionSave = complitionSave
        cameraViewController.maximumVideoLength = 36000
        cameraViewController.squareMode = false
        
        self.cameraContoler = cameraViewController
        self.parentVC?.present(cameraViewController, animated: true, completion: {
            guard let presentComplition = presentComplition else { return }
            presentComplition()
        })
    }
    
    public func close(_ image: UIImage) {

        self.image = image
        self.startEditing(again: true)

    }
}

