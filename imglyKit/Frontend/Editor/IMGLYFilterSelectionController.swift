//
//  IMGLYFilterSelectionController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 08/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

private let FilterCollectionViewCellReuseIdentifier = "FilterCollectionViewCell"
private let FilterCollectionViewCellSize = CGSize(width: 60, height: 90)
private let FilterActivationDuration = TimeInterval(0.15)

public var FilterPreviews = [IMGLYFilterType : UIImage]()

public typealias IMGLYFilterTypeSelectedBlock = (IMGLYFilterType) -> (Void)
public typealias IMGLYFilterTypeActiveBlock = () -> (IMGLYFilterType?)

open class IMGLYFilterSelectionController: UICollectionViewController {
    
    // MARK: - Properties
    
    fileprivate var selectedCellIndex: Int?
    open var selectedBlock: IMGLYFilterTypeSelectedBlock?
    open var activeFilterType: IMGLYFilterTypeActiveBlock?
    open var previewImage: UIImage? = nil

    // MARK: - Initializers
    
    init() {
        if previewImage != nil {
            previewImage = nil
        }
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = FilterCollectionViewCellSize
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        flowLayout.minimumInteritemSpacing = 7
        flowLayout.minimumLineSpacing = 7
        super.init(collectionViewLayout: flowLayout)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.register(IMGLYFilterCollectionViewCell.self, forCellWithReuseIdentifier: FilterCollectionViewCellReuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYFilterSelectionController {
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return IMGLYInstanceFactory.availableFilterList.count
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCollectionViewCellReuseIdentifier, for: indexPath) 
        
        if let filterCell = cell as? IMGLYFilterCollectionViewCell {
            let bundle = Bundle(for: type(of: self))
            let filterType = IMGLYInstanceFactory.availableFilterList[indexPath.item]
            let filter = IMGLYInstanceFactory.effectFilterWithType(filterType)
            
            filterCell.textLabel.text = filter.imgly_displayName
            filterCell.imageView.layer.cornerRadius = 3
            filterCell.imageView.clipsToBounds = true
            filterCell.imageView.contentMode = .scaleToFill
            filterCell.imageView.image = FilterPreviews[filterType]
            filterCell.hideTick()
            if FilterPreviews[filterType] == nil{

                    let previewImage: UIImage = self.previewImage ?? UIImage(named: "nonePreview", in: bundle, compatibleWith:nil)!

                    let imageSize = previewImage.size

                    let width: CGFloat
                    let x: CGFloat
                    let y: CGFloat
                    if imageSize.width < imageSize.height{
                        width =  imageSize.width
                        x = 0
                        y = (imageSize.height - width) / 2
                    }else{
                        width = imageSize.height
                        x = ( imageSize.width - width) / 2
                        y = 0
                    }


                    let rect = CGRect(x: x, y: y, width: width, height: width)

                    let cgImage = previewImage.cgImage!.cropping(to: rect)

                    let image = UIImage(cgImage: cgImage!)

                    let filterPreviewImage = IMGLYPhotoProcessor.processWithUIImage(image, filters: [filter])
                    
                    DispatchQueue.main.async {
                        FilterPreviews[filterType] = filterPreviewImage
                        if let filterCell = collectionView.cellForItem(at: indexPath) as? IMGLYFilterCollectionViewCell {
                            self.updateCell(filterCell, atIndexPath: indexPath, withFilterType: filter.filterType, forImage: filterPreviewImage)
                            filterCell.activityIndicator.stopAnimating()
                        }
                        collectionView.reloadItems(at: [indexPath])
                    }
                }
        }
        
        return cell
    }
    
    // MARK: - Helpers

    fileprivate func updateCell(_ cell: IMGLYFilterCollectionViewCell, atIndexPath indexPath: IndexPath, withFilterType filterType: IMGLYFilterType, forImage image: UIImage?) {
        cell.imageView.image = image

        if let activeFilterType = activeFilterType?(), activeFilterType == filterType {
            cell.showTick()
            selectedCellIndex = indexPath.item
        }
    }
}

extension IMGLYFilterSelectionController {
    open override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let layoutAttributes = collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath) {
            let extendedCellRect = layoutAttributes.frame.insetBy(dx: -60, dy: 0)
            collectionView.scrollRectToVisible(extendedCellRect, animated: true)
        }
        
        let filterType = IMGLYInstanceFactory.availableFilterList[indexPath.item]
        
        if selectedCellIndex == indexPath.item {
            selectedBlock?(filterType)
            return
        }
        
        // get cell of previously selected filter if visible
        if let selectedCellIndex = self.selectedCellIndex, let cell = collectionView.cellForItem(at: IndexPath(item: selectedCellIndex, section: 0)) as? IMGLYFilterCollectionViewCell {
            UIView.animate(withDuration: FilterActivationDuration, animations: { () -> Void in
                cell.hideTick()
            })
        }
        
        selectedBlock?(filterType)
        
        // get cell of newly selected filter
        if let cell = collectionView.cellForItem(at: indexPath) as? IMGLYFilterCollectionViewCell {
            selectedCellIndex = indexPath.item
            
            UIView.animate(withDuration: FilterActivationDuration, animations: { () -> Void in
                cell.showTick()
            })
        }
    }
}
