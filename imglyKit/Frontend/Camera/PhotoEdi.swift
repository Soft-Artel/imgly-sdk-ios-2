//
//  PhtoEditor.swift
//  imglyKit iOS
//
//  Created by Мурат Камалов on 05.12.2019.
//  Copyright © 2019 9elements GmbH. All rights reserved.
//

import UIKit
import AVFoundation

let InitialFilterIntensity = Float(0.75)
private let ShowFilterIntensitySliderInterval = TimeInterval(2)
private let FilterSelectionViewHeight = 100
private let BottomControlSize = CGSize(width: 47, height: 47)

open class PhotoEditor{
    
    static var saveToAlbum: Bool = true
    static var saveToEntryVC: (() -> ())? = nil
    var image: UIImage?
    weak var delegateImage: SaveImageDelegate?
    let parentVC: UIViewController?
    var photoEditor: PhotoEditor? = nil
    public var complition: ((Bool) -> ())? = nil
    
    internal var again = false
    
    var complitionSave : ((Bool) -> ())? = nil
    
    var cameraContoler: CameraCloseDelegate? = nil
    public init(image: UIImage?, delegate: SaveImageDelegate? = nil ,parent: UIViewController?, complit: ((Bool) -> ())? = nil, saveToSimplanum: Bool = false) {
        PhotoEditor.saveToAlbum = saveToSimplanum
        self.image = image
        self.delegateImage = delegate
        self.parentVC = parent
        self.complition = complit
        self.photoEditor = self
    }
    
    deinit {
        
    }
    
    public init(parent: UIViewController){
        self.parentVC = parent
        self.photoEditor = self
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    public func startEditing(again: Bool = false, cameraContoler: CameraCloseDelegate? = nil, isMagic: Bool = false){
        if self.photoEditor == nil{
            self.photoEditor = self
        }
        let editorViewController = IMGLYMainEditorViewController()
        IMGLYEditorViewController.isMagic = isMagic
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
        navigationController.navigationBar.isHidden = false

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
    
    /// Используется для открытия камеры перед фоторедактором
    /// - Parameters:
    ///   - complitionSave: комплишен который вызывается после закрытия фотопикер возвращает true если были применены фильрры
    ///   - presentComplition: комплишен который вызывается после соранения
    ///   - withCamera: true фотопикер с видео камерой
    ///   - afterOpenGallery: делегат который привязывается для открытие сторонней библиотеки или же контроллера
    ///   - defaultIsFront: true открывает по дефолту фронталку
    public func openCamera(with complitionSave: ((Bool) -> ())?, presentComplition: (() -> ())? = nil, withCamera: Bool = true, afterOpenGallery: GalleryDelegate? = nil, defaultIsFront: Bool = false){
        
        var recordingMode: [IMGLYRecordingMode] = [.photo]
        if withCamera{
            recordingMode.append(.video)
        }
        let cameraViewController = IMGLYCameraViewController(recordingModes: recordingMode)
        
        self.complitionSave = complitionSave
        cameraViewController.comlitionSave = complitionSave
        cameraViewController.cameraDelegate = cameraViewController//self.cameraContoler
        cameraViewController.maximumVideoLength = 0
        cameraViewController.squareMode = false
        cameraViewController.delegateEditor = self.delegateImage
        cameraViewController.galleryDelegate = afterOpenGallery
        cameraViewController.defaultIsFront = defaultIsFront
        
        self.cameraContoler = cameraViewController
        self.parentVC?.modalPresentationStyle = .fullScreen
        self.parentVC?.present(cameraViewController, animated: true, completion: {
            guard let presentComplition = presentComplition else { return }
            presentComplition()
        })
    }
    
    public func close(_ image: UIImage, isMagic: Bool) {

        self.image = image
        self.again = true
        self.startEditing(again: true, isMagic: isMagic)

    }
}

