//
//  ViewControllerrr.swift
//  imglyKit iOS
//
//  Created by Мурат Камалов on 29.11.2019.
//  Copyright © 2019 9elements GmbH. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import Photos

class ViewControllerrr: UIViewController {



        override func viewDidLoad() {
                super.viewDidLoad()
                let btn = UIButton(frame: CGRect(x: 100, y: 100, width: 50, height: 50))
                self.view.addSubview(btn)
                btn.backgroundColor = .red
                btn.addTarget(self, action: #selector(takePhoto(_:)), for: .allEvents)

                if IMGLYCameraViewController._shared == nil {
                    IMGLYCameraViewController._shared = self
                }
            }


           func showEditorNavigationControllerWithImage(_ image: UIImage = UIImage(named: "testingImage")!) {
                self.present(ViewController(), animated: true, completion: nil)
        //        let editorViewController = IMGLYMainEditorViewController()
        //        editorViewController.highResolutionImage = image
        //
        //        let navigationController = IMGLYNavigationController(rootViewController: editorViewController)
        //        navigationController.navigationBar.barStyle = .black
        //        navigationController.navigationBar.isTranslucent = false
        //        navigationController.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor : UIColor.white ]
        //        navigationController.modalPresentationStyle = .overFullScreen
        //
        //        self.present(navigationController, animated: true, completion: nil)

        //        IMGLYMainEditorViewController.showEditor(image: image, parent: self)

            }

            @objc func takePhoto(_ sender: UIButton?) {
                self.showEditorNavigationControllerWithImage()
            }
            

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
