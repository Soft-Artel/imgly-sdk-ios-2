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
    var complition: ((Bool) -> ())? = nil
    public init(image: UIImage?, delegate: SaveImageDelegate? = nil ,parent: UIViewController?, complit: ((Bool) -> ())? = nil) {
        self.image = image
        self.delegateImage = delegate
        self.parentVC = parent
        self.complition = complit
        self.photoEditor = self
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    public func startEditing(again: Bool = false){
        if self.photoEditor == nil{
            self.photoEditor = self
        }
        let editorViewController = IMGLYMainEditorViewController()
        editorViewController.delegateEditor = self.delegateImage
        editorViewController.photoPickerComplition = self.complition
        editorViewController.highResolutionImage = self.image
        editorViewController.photoEditor = self.photoEditor
        let navigationController = IMGLYNavigationController(rootViewController: editorViewController)
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor : UIColor.white ]
        navigationController.modalPresentationStyle = .overFullScreen

        if again{
            editorViewController.animateSeque = true
        }

        parentVC?.present(navigationController, animated: false, completion: nil)


    }

    public func close(_ image: UIImage) {

        self.image = image
        self.startEditing(again: true)

    }
}

