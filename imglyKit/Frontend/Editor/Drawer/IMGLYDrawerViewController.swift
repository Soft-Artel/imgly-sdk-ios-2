//
//  IMGLYDrawerViewController.swift
//  imglyKit iOS
//
//  Created by Мурат Камалов on 21.11.2019.
//  Copyright © 2019 9elements GmbH. All rights reserved.
//

import UIKit

open class IMGLYDrawerViewController: IMGLYSubEditorViewController{

    open fileprivate(set) lazy var mainImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        return view
    }()

    var tempImageView = UIImageView()
    var backButton = UIButton()
    var lineArray = [UIImage]()

    //    var drawerView: DrawingView?
    open fileprivate(set) lazy var textColorSelectorView: IMGLYTextColorSelectorView = {
        let view = IMGLYTextColorSelectorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.menuDelegate = self
        return view
    }()

    fileprivate var tempStickersClipView = [CIFilter]()


    open override func tappedDone(_ sender: UIBarButtonItem?) {
        var addedStickers = false

        if let image = mainImageView.image{
            let drawFilter = IMGLYInstanceFactory.drawFilter()
            drawFilter.paint = image
            let center = CGPoint(x: mainImageView.center.x / self.previewImageView.frame.size.width,
                                 y: mainImageView.center.y / self.previewImageView.frame.size.height)

            var size = self.previewImageView.frame.size
            size.width = size.width / self.previewImageView.imageView.bounds.size.width
            size.height = size.height / self.previewImageView.imageView.bounds.size.height
            drawFilter.center = center
            drawFilter.scale = 1// size.width
            drawFilter.transform = view.transform
            fixedFilterStack.drawFilter.append(drawFilter)
            addedStickers = true
        }

        if addedStickers{
            updatePreviewImageWithCompletion {
                super.tappedDone(sender)
            }
        }else{
            super.tappedDone(sender)
        }
    }

    var lastPoint = CGPoint.zero
    var color = UIColor.black
    var brushWidth: CGFloat = 20.0
    var opacity: CGFloat = 1.0
    var swiped = false

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.previewImageView.imageView.backgroundColor = .green
        let bundle = Bundle(for: type(of: self))
        navigationItem.title = NSLocalizedString("Рисовалка", tableName: nil, bundle: bundle, value: "", comment: "")

        self.view.addSubview(self.mainImageView)
        self.view.addSubview(self.tempImageView)

        self.tempImageView.translatesAutoresizingMaskIntoConstraints = false
        self.tempImageView.topAnchor.constraint(equalTo: self.previewImageView.imageView.topAnchor).isActive = true
        self.tempImageView.leftAnchor.constraint(equalTo: self.previewImageView.imageView.leftAnchor).isActive = true
        self.tempImageView.rightAnchor.constraint(equalTo: self.previewImageView.imageView.rightAnchor).isActive = true
        self.tempImageView.bottomAnchor.constraint(equalTo: self.previewImageView.imageView.bottomAnchor).isActive = true

        self.mainImageView.translatesAutoresizingMaskIntoConstraints = false
        self.mainImageView.topAnchor.constraint(equalTo: self.tempImageView.topAnchor).isActive = true
        self.mainImageView.leftAnchor.constraint(equalTo: self.tempImageView.leftAnchor).isActive = true
        self.mainImageView.rightAnchor.constraint(equalTo: self.tempImageView.rightAnchor).isActive = true
        self.mainImageView.bottomAnchor.constraint(equalTo: self.tempImageView.bottomAnchor).isActive = true

        self.configureColorSelectorView()

//        self.backButton.backgroundColor = .red
//        self.backButton.layer.cornerRadius = self.backButton.frame.height / 2
        self.backButton.addTarget(self, action: #selector(self.undoAction), for: .touchUpInside)
        let btnImage = UIImage(named: "back-button", in: Bundle(for: type(of: self)), compatibleWith:nil)
        self.backButton.setImage(btnImage, for: .normal)
        self.view.addSubview(self.backButton)
    }

    @objc func undoAction(){
        if self.lineArray.count != 0 {
            self.lineArray.removeLast()
        }else{
            return
        }
        let imageView = UIImageView()
        for line in lineArray{
            UIGraphicsBeginImageContext(self.previewImageView.frame.size)
            imageView.image?.draw(in: self.previewImageView.frame, blendMode: .normal, alpha: 1.0)
            line.draw(in: self.previewImageView.frame, blendMode: .normal, alpha: opacity)
            imageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        self.mainImageView.image = imageView.image
    }

    fileprivate func configureColorSelectorView(){
        self.bottomContainerView.addSubview(self.textColorSelectorView)

        let views = [
            "textColorSelectorView" : self.textColorSelectorView
        ]

        self.bottomContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[textColorSelectorView]|", options: [], metrics: nil, views: views))
        self.bottomContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[textColorSelectorView]|", options: [], metrics: nil, views: views))
    }


    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tempImageView.layoutIfNeeded()
        self.mainImageView.layoutIfNeeded()

        self.tempImageView.transform = self.previewImageView.imageView.transform
        self.mainImageView.transform = self.tempImageView.transform

        //        self.mainImageView = UIImageView()

        //        if let lowResolutionImage = self.lowResolutionImage {
        //            let processedImage = IMGLYPhotoProcessor.processWithUIImage(lowResolutionImage, filters: self.fixedFilterStack.activeFilters)
        //            self.previewImageView.image = processedImage
        //        }

        //        if let frames = self.imageFrame{
        //            self.tempImageView.frame = frames
        //            self.mainImageView.frame = self.tempImageView.frame
        //        }else{
//        self.tempImageView.frame = self.imageFrame ?? self.view.frame
//        //        self.tempImageView.frame.size.height = self.previewImageView.visibleImageFrame.height - self.previewImageView.visibleImageFrame.origin.y
//        //        self.tempImageView.center.y = self.bottomContainerView.frame.origin.y / 2
//        self.tempImageView.center.x = self.previewImageView.center.x
//        self.mainImageView.frame = self.tempImageView.frame
//        //        }

        self.backButton.frame = CGRect(x: self.view.frame.origin.x + 50,
                                       y: bottomContainerView.frame.origin.y - 50,
                                       width: 50, height: 50)
    }

    // MARK: - Actions

    func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
        UIGraphicsBeginImageContext(tempImageView.bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        tempImageView.image?.draw(in: self.tempImageView.bounds)

        context.move(to: fromPoint)
        context.addLine(to: toPoint)

        context.setLineCap(.round)
        context.setBlendMode(.color)
        context.setLineWidth(brushWidth)
        context.setStrokeColor(color.cgColor)

        context.strokePath()

        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.tempImageView.layoutIfNeeded()
        self.mainImageView.layoutIfNeeded()

        guard let touch = touches.first else {
            return
        }
        swiped = false
        lastPoint = touch.location(in: self.tempImageView)

    }

    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        swiped = true
        let currentPoint = touch.location(in: self.tempImageView)
        drawLine(from: lastPoint, to: currentPoint)

        lastPoint = currentPoint
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            // draw a single point
            drawLine(from: lastPoint, to: lastPoint)
        }

        guard let image = self.tempImageView.image else { return }
        self.lineArray.append(image)

        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(self.mainImageView.bounds.size)
        mainImageView.image?.draw(in: tempImageView.bounds, blendMode: .normal, alpha: 1.0)
        tempImageView.image?.draw(in: tempImageView.bounds, blendMode: .normal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        tempImageView.image = nil

    }

    // MARK: - SettingsViewControllerDelegate

}

extension IMGLYDrawerViewController: IMGLYTextColorSelectorViewDelegate, UIPopoverPresentationControllerDelegate {
    public func textColorSelectorView(_ selectorView: IMGLYTextColorSelectorView, didSelectColor color: UIColor) {
        self.color = color
    }
}



