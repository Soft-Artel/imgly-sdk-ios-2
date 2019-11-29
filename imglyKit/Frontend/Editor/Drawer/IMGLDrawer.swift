//
//  IMGLDrawer.swift
//  imglyKit iOS
//
//  Created by Мурат Камалов on 22.11.2019.
//  Copyright © 2019 9elements GmbH. All rights reserved.
//

import UIKit

open class IMGLDrawer: NSObject {
    public let image: UIImage
    public let thumbnail: UIImage?

    public init(image: UIImage, thumbnail: UIImage?) {
        self.image = image
        self.thumbnail = thumbnail
        super.init()
    }
}
