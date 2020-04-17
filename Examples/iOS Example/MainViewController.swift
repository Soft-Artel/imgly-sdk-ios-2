//
//  MainViewController.swift
//  iOS Example
//
//  Created by Мурат Камалов on 05.12.2019.
//  Copyright © 2019 9elements GmbH. All rights reserved.
//

import UIKit
import imglyKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .green
                // Do any additional setup after loading the view.

        let btn = UIButton(frame: CGRect(x: 100, y: 100, width: 50, height: 50))
        self.view.addSubview(btn)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(takePhoto(_:)), for: .allEvents)

        let btn1 = UIButton(frame: CGRect(x: 50, y: 50, width: 50, height: 50))
        self.view.addSubview(btn1)
        btn1.backgroundColor = .red
        btn1.addTarget(self, action: #selector(takePhoto1(_:)), for: .allEvents)

        let btn2 = UIButton(frame: CGRect(x: 150, y: 150, width: 50, height: 50))
        self.view.addSubview(btn2)
        btn2.backgroundColor = .red
        btn2.addTarget(self, action: #selector(takePhoto2(_:)), for: .allEvents)

        let btn3 = UIButton(frame: CGRect(x: 150, y: 205, width: 50, height: 50))
        self.view.addSubview(btn3)
        btn3.backgroundColor = .red
        btn3.addTarget(self, action: #selector(takePhoto3(_:)), for: .allEvents)

        let btn4 = UIButton(frame: CGRect(x: 150, y: 260, width: 50, height: 50))
        self.view.addSubview(btn4)
        btn4.backgroundColor = .red
        btn4.addTarget(self, action: #selector(takePhoto4(_:)), for: .allEvents)
    }

    @objc open func takePhoto(_ sender: UIButton?) {

        let image = UIImage(named: "testingImage")!

//        let editor = PhotoEditor(image: image, delegate: self, parent: self)
//        editor.startEditing()
        let editor = PhotoEditor(image: nil, delegate: self, parent: self, complit: nil)
        
        editor.openCamera(with: { (isOnlyPicker) in
            if isOnlyPicker{
                print("Закрываем тоже его")
            }else{
                print("Не закрываем и выделяем")
            }
        }, withCamera: false)

    }

    @objc open func takePhoto1(_ sender: UIButton?) {

        let image = UIImage(named: "Image-1")!

        let editor = PhotoEditor(image: image, delegate: self, parent: self)
        editor.startEditing()

    }

    @objc open func takePhoto2(_ sender: UIButton?) {

        let image = UIImage(named: "Image-3")!

        let editor = PhotoEditor(image: image, delegate: self, parent: self)
        editor.startEditing()

    }

    @objc open func takePhoto3(_ sender: UIButton?) {

        let image = UIImage(named: "Image-4")!

        let editor = PhotoEditor(image: image, delegate: self, parent: self)
        editor.startEditing()

    }

    @objc open func takePhoto4(_ sender: UIButton?) {

        let image = UIImage(named: "testingImage")!

        let editor = PhotoEditor(image: image, delegate: self, parent: self)
        editor.startEditing()

    }

}

extension MainViewController: SaveImageDelegate{
    func saveImage(_ image: UIImage) {
        print("сохранил")
    }
}

