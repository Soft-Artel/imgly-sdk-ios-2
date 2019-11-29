//
//  ViewController.swift
//  imglyKit iOS
//
//  Created by Мурат Камалов on 29.11.2019.
//  Copyright © 2019 9elements GmbH. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .green
        // Do any additional setup after loading the view.

        let btn = UIButton(frame: CGRect(x: 100, y: 100, width: 50, height: 50))
        self.view.addSubview(btn)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(takePhoto(_:)), for: .allEvents)
    }

    @objc open func takePhoto(_ sender: UIButton?) {

        let image = UIImage(named: "testingImage")!
//        let editorViewController = IMGLYMainEditorViewController()
//        editorViewController.highResolutionImage = image
//        
//        let navigationController = IMGLYNavigationController(rootViewController: editorViewController)
//        navigationController.navigationBar.barStyle = .black
//        navigationController.navigationBar.isTranslucent = false
//        navigationController.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor : UIColor.white ]
//        navigationController.modalPresentationStyle = .overFullScreen
//        
//                self.present(navigationController, animated: true, completion: nil)

                IMGLYMainEditorViewController.showEditor(image: image, parent: self)
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
