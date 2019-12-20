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
    }

    @objc open func takePhoto(_ sender: UIButton?) {

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

