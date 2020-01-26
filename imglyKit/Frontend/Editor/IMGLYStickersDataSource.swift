//
//  IMGLYStickersDataSource.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 23/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public protocol IMGLYStickersDataSourceDelegate: class, UICollectionViewDataSource {
    var stickers: [IMGLYSticker] { get }
}

open class IMGLYStickersDataSource: NSObject, IMGLYStickersDataSourceDelegate {
    public let stickers: [IMGLYSticker]
    
    override init() {
        let stickerFiles = [
            "boy-min".localized,
            "close-min".localized,
            "dollar-min".localized,
            "fire-min".localized,
            "girl-min".localized,
            "good-min".localized,
            "heart-min".localized,
            "idea-min".localized,
            "open-min".localized,
            "paperplane-min".localized,
            "pen-min".localized,
            "plane-min".localized,
            "redarrow-min".localized,
            "rise-min".localized,
            "whitearrow-min".localized,
            "word1-min".localized,
            "word2-min".localized,
            "word3-min".localized,
            "word4-min".localized,
            "word5-min".localized,
            "word6-min".localized,
            "word7-min".localized,
            "word8-min".localized,
            "word9-min".localized,
            "yellowarrow-min".localized
        ]
        
        stickers = stickerFiles.map { (file: String) -> IMGLYSticker? in
            if let image = UIImage(named: file, in: Bundle(for: IMGLYStickersDataSource.self), compatibleWith: nil) {
                let thumbnail = UIImage(named: file + "_thumbnail", in: Bundle(for: IMGLYStickersDataSource.self), compatibleWith: nil)
                return IMGLYSticker(image: image, thumbnail: thumbnail)
            }
            
            return nil
            }.filter { $0 != nil }.map { $0! }
        
        super.init()
    }
    
    public init(stickers: [IMGLYSticker]) {
        self.stickers = stickers
        super.init()
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickers.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StickersCollectionViewCellReuseIdentifier, for: indexPath) as! IMGLYStickerCollectionViewCell
        
        cell.imageView.image = stickers[indexPath.row].thumbnail ?? stickers[indexPath.row].image
        
        return cell
    }
}
