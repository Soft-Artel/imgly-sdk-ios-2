//
//  IMGLYDrawDataSource.swift
//  imglyKit iOS
//
//  Created by Мурат Камалов on 22.11.2019.
//  Copyright © 2019 9elements GmbH. All rights reserved.
//

import UIKit

public protocol IMGLYDraweDataSourceDelegate: class, UICollectionViewDataSource{
    var colors: [IMGLDrawer] { get } //поменять тип
}

class IMGLYDrawDataSource: NSObject {
    //создать модель
}
