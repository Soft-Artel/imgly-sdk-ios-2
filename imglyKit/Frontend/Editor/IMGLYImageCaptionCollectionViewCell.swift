//
//  IMGLYImageCaptionCollectionViewCell.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 08/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

class IMGLYImageCaptionCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
        }()
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = UIColor(white: 0.5, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        configureViews()
    }
    
    // MARK: - Helpers
    
    fileprivate func configureViews() {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageView)
        containerView.addSubview(textLabel)
        
        contentView.addSubview(containerView)

        self.textLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        self.textLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true

        containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.textLabel.topAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
        containerView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true

        self.imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        self.imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.imageView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor).isActive = true

    }
    
    // MARK: - Subclasses
    
    var imageSize: CGSize {
        // Subclasses should override this
        return CGSize.zero
    }
    
    var imageCaptionMargin: CGFloat {
        // Subclasses should override this
        return 0
    }
    
}
