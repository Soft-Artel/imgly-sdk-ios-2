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
            "boy-min",
            "close-min",
            "dollar-min",
            "fire-min",
            "girl-min",
            "good-min",
            "heart-min",
            "idea-min",
            "open-min",
            "paperplane-min",
            "pen-min",
            "plane-min",
            "redarrow-min",
            "rise-min",
            "whitearrow-min",
            "word1-min",
            "word2-min",
            "word3-min",
            "word4-min",
            "word5-min",
            "word6-min",
            "word7-min",
            "word8-min",
            "word9-min",
            "yellowarrow-min"
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
