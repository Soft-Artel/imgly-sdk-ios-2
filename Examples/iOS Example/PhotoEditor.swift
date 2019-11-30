//
//  FirstViewController.swift
//  iOS Example
//
//  Created by Мурат Камалов on 30.11.2019.
//  Copyright © 2019 9elements GmbH. All rights reserved.
//

import UIKit
import imglyKit

open class PhotoEditor: UIViewController {

    override open func viewDidLoad() {
        super.viewDidLoad()

    }

    public func showPhotoEditor(image: UIImage, parent: UIViewController){
        IMGLYMainEditorViewController.showEditor(image: image, parent: parent)
    }
    
    @objc func takePhoto(){
//        IMGLYMainEditorViewController.showEditor(image: , parent: <#T##UIViewController#>)
    }
    

}
