//
//  IMGLYDrawerViewController.swift
//  imglyKit iOS
//
//  Created by Мурат Камалов on 21.11.2019.
//  Copyright © 2019 9elements GmbH. All rights reserved.
//

import UIKit

open class IMGLYDrawerViewController: IMGLYSubEditorViewController, UIPopoverControllerDelegate{

    open fileprivate(set) lazy var mainImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        return view
    }()
    var tempImageView: UIImageView!
    var backButton = UIButton()
    var lineArray = [UIImage]()
    
//    var drawerView: DrawingView?
    open fileprivate(set) lazy var textColorSelectorView: IMGLYTextColorSelectorView = {
        let view = IMGLYTextColorSelectorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.menuDelegate = self
        return view
    }()

    open fileprivate(set) lazy var backgroundView: UIView = {
        let view = UIView()
        view.clipsToBounds =  true
        return view
    }()


    fileprivate var dragView: UIView?
    fileprivate var tempStickersClipView = [CIFilter]()
    

    open override func tappedDone(_ sender: UIBarButtonItem?) {
        var addedStickers = false

        if let image = mainImageView.image{
            let drawFilter = IMGLYInstanceFactory.drawFilter()
            drawFilter.paint = image
            let center = CGPoint(x: mainImageView.center.x / backgroundView.frame.size.width,
                                 y: mainImageView.center.y / backgroundView.frame.size.height)

            var size = self.backgroundView.frame.size
            size.width = size.width / backgroundView.bounds.size.width
            size.height = size.height / backgroundView.bounds.size.height
            drawFilter.center = center
            drawFilter.scale = size.width
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
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false

    open override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(backgroundView)
        let bundle = Bundle(for: type(of: self))
        navigationItem.title = NSLocalizedString("Рисовалка", tableName: nil, bundle: bundle, value: "", comment: "")

        self.configureColorSelectorView()

    }

    @objc func undoAction(){
        if self.lineArray.count != 0 {
            self.lineArray.removeLast()
        }else{
            return
        }
        let imageView = UIImageView()
        for line in lineArray{
            UIGraphicsBeginImageContext(backgroundView.frame.size)
            imageView.image?.draw(in: backgroundView.frame, blendMode: .normal, alpha: 1.0)
            line.draw(in: backgroundView.frame, blendMode: .normal, alpha: opacity)
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

        self.tempImageView = UIImageView()
        self.mainImageView = UIImageView()
        self.tempImageView.frame = view.convert(previewImageView.visibleImageFrame, from: previewImageView)
        self.mainImageView.frame = view.convert(previewImageView.visibleImageFrame, from: previewImageView)
        self.view.addSubview(self.tempImageView)
        self.view.addSubview(self.mainImageView)

        self.backgroundView.frame = view.convert(previewImageView.visibleImageFrame, from: previewImageView)

        self.backButton.frame = CGRect(x: self.view.frame.origin.x + 20,
                                       y: bottomContainerView.frame.origin.y - 20,
                                              width: 30, height: 30)
        self.backButton.backgroundColor = .red
        self.backButton.layer.cornerRadius = self.backButton.frame.height / 2
        self.backButton.addTarget(self, action: #selector(self.undoAction), for: .touchUpInside)
        self.view.addSubview(self.backButton)

    }



      // MARK: - Actions

      func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
        UIGraphicsBeginImageContext(self.backgroundView.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else {
          return
        }
        tempImageView.image?.draw(in: self.backgroundView.frame)

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
        guard let touch = touches.first else {
          return
        }
        self.backgroundView.frame = self.previewImageView.visibleImageFrame
        swiped = false
        lastPoint = touch.location(in: self.backgroundView)
      }

    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
          return
        }
        swiped = true
        let currentPoint = touch.location(in: self.backgroundView)
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
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.draw(in: backgroundView.frame, blendMode: .normal, alpha: 1.0)
        tempImageView?.image?.draw(in: backgroundView.frame, blendMode: .normal, alpha: opacity)
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



