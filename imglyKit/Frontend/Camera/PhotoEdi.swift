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
    
    static var saveToEntryVC: (() -> ())? = nil
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
//            editorViewController.reopenCamera = reopen
            cameraContoler?.present(view: navigationController)
        }else{
            parentVC?.present(navigationController, animated: false, completion: nil)
        }
    }
        
    public func openCamera(with complitionSave: (() -> ())?, presentComplition: (() -> ())? = nil){
        
        
        let cameraViewController = IMGLYCameraViewController(recordingModes: [.photo, .video])
        
        self.complitionSave = complitionSave
        cameraViewController.comlitionSave = complitionSave
        cameraViewController.cameraDelegate = self.cameraContoler
        cameraViewController.comlitionSave = complitionSave
        cameraViewController.maximumVideoLength = 0
        cameraViewController.squareMode = false
        cameraViewController.delegateEditor = self.delegateImage
        
        self.cameraContoler = cameraViewController
        self.parentVC?.modalPresentationStyle = .fullScreen
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

