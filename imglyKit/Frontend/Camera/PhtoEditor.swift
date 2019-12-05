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
    let delegateImage: SaveImageDelegate?
    let parentVC: UIViewController?
    public var delegateVC: PhotoEditor? = nil
    let editorViewController = IMGLYMainEditorViewController()

    public init(image: UIImage, delegate: SaveImageDelegate,parent: UIViewController) {
        self.image = image
        self.delegateImage = delegate
        self.parentVC = parent
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    public func startEditing(){
        self.editorViewController.highResolutionImage = self.image
        self.editorViewController.delegateEditor = self.delegateImage
        self.editorViewController.photoEditorDelegate = self.delegateVC
        let navigationController = IMGLYNavigationController(rootViewController: editorViewController)
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor : UIColor.white ]
        navigationController.modalPresentationStyle = .overFullScreen

        parentVC?.present(navigationController, animated: false, completion: nil)

    }



}

extension PhotoEditor: DoneEditDelegate{
    public func close(_ image: UIImage) {

        self.image = image
        self.startEditing()

    }
}

