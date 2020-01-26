//
//  StringExtension.swift
//  imglyKit iOS
//
//  Created by Мурат Камалов on 26.01.2020.
//  Copyright © 2020 9elements GmbH. All rights reserved.
//

import Foundation

extension String{
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
