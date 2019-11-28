//
//  IMGLYCropRectComponent.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 23/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

open class IMGLYCropRectComponent {
    open var cropRect = CGRect.zero

    fileprivate var topLineView_:UIView = UIView(frame: CGRect.zero)
    fileprivate var bottomLineView_:UIView = UIView(frame: CGRect.zero)
    fileprivate var leftLineView_:UIView = UIView(frame: CGRect.zero)
    fileprivate var rightLineView_:UIView = UIView(frame: CGRect.zero)

    open var topLeftAnchor_:UIImageView?
    open var topRightAnchor_:UIImageView?
    open var bottomLeftAnchor_:UIImageView?
    open var bottomRightAnchor_:UIImageView?
    fileprivate var transparentView_:UIView?
    fileprivate var parentView_:UIView?
    fileprivate var showAnchors_ = true

    fileprivate var originX: CGFloat = 0
    fileprivate var originY: CGFloat = 0
    fileprivate var sizeWidth: CGFloat = 0
    fileprivate var sizeHeight: CGFloat = 0

    fileprivate var left: CGFloat = 0
    fileprivate var right: CGFloat = 0
    fileprivate var top: CGFloat = 0
    fileprivate var bottom: CGFloat = 0
    fileprivate var width: CGFloat = 0
    fileprivate var height: CGFloat = 0

    // call this in viewDidLoad
    open func setup(_ transparentView:UIView, parentView:UIView, showAnchors:Bool) {
        transparentView_ = transparentView
        parentView_ = parentView
        showAnchors_ = showAnchors
        setupLineViews()
        setupAnchors()
    }

    // call this in viewDidAppear
    open func present(_ transparentViewFrame: CGRect) {
        layoutViewsForCropRect(transparentViewFrame)
        showViews()
    }
    
    fileprivate func setupLineViews() {
        cropRect = CGRect(x: 100, y: 100, width: 150, height: 100)
        setupLineView(topLineView_)
        setupLineView(bottomLineView_)
        setupLineView(leftLineView_)
        setupLineView(rightLineView_)
    }

    fileprivate func setupLineView(_ lineView:UIView) {
        lineView.backgroundColor = UIColor.white
        lineView.isHidden = true
        parentView_!.addSubview(lineView)
    }
    
    fileprivate func addMaskRectView(_ transparentViewFrame: CGRect) {

        let frames = CGRect(x: self.originX - self.transparentView_!.frame.origin.x,
                            y: self.originY - self.transparentView_!.frame.origin.y,
        width: self.topLineView_.frame.width,
        height: self.leftLineView_.frame.height)

        let shapeLayer = CAShapeLayer()

        shapeLayer.frame = transparentViewFrame
        shapeLayer.fillColor = UIColor.black.cgColor
        shapeLayer.fillRule = CAShapeLayerFillRule.evenOdd

        let innerPath = UIBezierPath(rect: shapeLayer.bounds.insetBy(dx: 0.0, dy: 0.0))
        let outerPath = UIBezierPath(rect: frames)

        let shapeLayerPath = UIBezierPath()
        shapeLayerPath.append(outerPath)
        shapeLayerPath.append(innerPath)

        shapeLayer.path = shapeLayerPath.cgPath


        self.leftLineView_.backgroundColor = .red
        self.topLineView_.backgroundColor = .green
        self.rightLineView_.backgroundColor = .yellow
        self.bottomLineView_.backgroundColor = .blue
        transparentView_!.layer.mask = shapeLayer
    }

    fileprivate func setupAnchors() {
        let anchorImage = UIImage(named: "crop_anchor", in: Bundle(for: type(of: self)), compatibleWith:nil)
        topLeftAnchor_ = createAnchorWithImage(anchorImage)
        topRightAnchor_ = createAnchorWithImage(anchorImage)
        bottomLeftAnchor_ = createAnchorWithImage(anchorImage)
        bottomRightAnchor_ = createAnchorWithImage(anchorImage)
    }
    
    fileprivate func createAnchorWithImage(_ image:UIImage?) -> UIImageView {
        let anchor = UIImageView(image: image!)
        anchor.contentMode = .center
        anchor.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        anchor.isHidden = true
        transparentView_!.addSubview(anchor)
        return anchor
    }
    
    // MARK:- layout
    open func layoutViewsForCropRect(_ transparentViewFrame: CGRect) {
        layoutLines()
        layoutAnchors()
        addMaskRectView(transparentViewFrame)
    }
    
    fileprivate func layoutLines() {
        self.left = cropRect.origin.x + transparentView_!.frame.origin.x
        self.originX = self.left
        self.right = left + cropRect.size.width - 1.0
        if self.right < self.originX { self.originX = self.right }
        self.top = cropRect.origin.y + transparentView_!.frame.origin.y
        self.originY = self.top
        self.bottom = top + cropRect.size.height - 1.0
        if self.bottom < self.originY { self.originY = self.bottom}
        self.width = cropRect.size.width
        self.height = cropRect.size.height
        
        leftLineView_.frame = CGRect(x: left, y: top, width: 1, height: height)
        rightLineView_.frame = CGRect(x: right, y: top, width: 1, height: height)
        topLineView_.frame = CGRect(x: left, y: top, width: width, height: 1)
        bottomLineView_.frame = CGRect(x: left, y: bottom, width: width, height: 1)
    }
    
    fileprivate func layoutAnchors() {
        let left = cropRect.origin.x
        let right = left + cropRect.size.width
        let top = cropRect.origin.y
        let bottom = top + cropRect.size.height
        topLeftAnchor_!.center = CGPoint(x: left, y: top)
        topRightAnchor_!.center = CGPoint(x: right, y: top)
        bottomLeftAnchor_!.center = CGPoint(x: left, y: bottom)
        bottomRightAnchor_!.center = CGPoint(x: right, y: bottom)
    }
    
    open func showViews() {
        if showAnchors_ {
            topLeftAnchor_!.isHidden = false
            topRightAnchor_!.isHidden = false
            bottomLeftAnchor_!.isHidden = false
            bottomRightAnchor_!.isHidden = false
        }
        leftLineView_.isHidden = false
        rightLineView_.isHidden = false
        topLineView_.isHidden = false
        bottomLineView_.isHidden = false
    }
}
