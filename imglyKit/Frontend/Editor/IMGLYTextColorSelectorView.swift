//
//  IMGLYTextColorSelectorView.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 05/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public protocol IMGLYTextColorSelectorViewDelegate: class {
    func textColorSelectorView(_ selectorView: IMGLYTextColorSelectorView, didSelectColor color: UIColor)
}

open class IMGLYTextColorSelectorView: UIScrollView, UIPopoverPresentationControllerDelegate {
    open weak var menuDelegate: IMGLYTextColorSelectorViewDelegate?
    
    fileprivate var colorArray = [UIColor]()
    fileprivate var buttonArray = [IMGLYColorButton]()
    fileprivate let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    fileprivate let kButtonYPosition = CGFloat(22)
    fileprivate let kButtonXPositionOffset = CGFloat(5)
    fileprivate let kButtonDistance = CGFloat(10)
    fileprivate let kButtonSideLength = CGFloat(50)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        self.autoresizesSubviews = false
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        configureColorArray()
        configureColorButtons()
    }
    
    fileprivate func configureColorArray() {
        colorArray = [
            UIColor.white,
            UIColor.black,
            UIColor(hex: "#008fae"),
            UIColor(hex: "#ff1f01"),
            UIColor(hex: "#ff9a11"),
            UIColor(hex: "#8e5595"),
            UIColor(hex: "#a2c923"),
            UIColor(hex: "#74b0cb"),
            UIColor(hex: "#ffbc1c"),
            UIColor(hex: "#c5b51d"),
            UIColor(hex: "#b698da"),
            UIColor(hex: "#898989"),
            UIColor(hex: "#056da1"),
            UIColor(hex: "#a3b8ee"),
            UIColor(hex: "#EB3024"),
            UIColor(hex: "#ff7c72"),
            UIColor(hex: "#ffa97a"),
            UIColor(hex: "#a18569"),
            UIColor(hex: "#63a66d"),
            UIColor(hex: "#bbbbbb")
        ]
    }
    
    fileprivate func configureColorButtons() {
        for color in colorArray {
            let button = IMGLYColorButton()
            self.addSubview(button)
            button.addTarget(self, action: #selector(IMGLYTextColorSelectorView.colorButtonTouchedUpInside(_:)), for: .touchUpInside)
            buttonArray.append(button)
            button.backgroundColor = color
            button.hasFrame = true
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        layoutColorButtons()
    }
    
    fileprivate func layoutColorButtons() {
        var xPosition = kButtonXPositionOffset
        for i in 0..<colorArray.count {
            let button = buttonArray[i]
            button.frame = CGRect(x: xPosition,
                y: kButtonYPosition,
                width: kButtonSideLength,
                height: kButtonSideLength)
            xPosition += (kButtonDistance + kButtonSideLength)
        }
        buttonArray[0].hasFrame = true
        contentSize = CGSize(width: xPosition - kButtonDistance + kButtonXPositionOffset, height: 0)
    }
    
    @objc fileprivate func colorButtonTouchedUpInside(_ button:UIButton) {
        menuDelegate?.textColorSelectorView(self, didSelectColor: button.backgroundColor!)
        
        self.blur.removeFromSuperview()
        self.blur.frame = CGRect(x: 0, y: 0, width: button.frame.width, height: button.frame.height)
        button.addSubview(self.blur)

//        if button == self.buttonArray[0]{
//            let  popoverVC = storyboard?.instantiateViewController(withIdentifier: "colorPickerPopover") as? ColorPickerViewController
//            popoverVC?.modalPresentationStyle = .popover
//            popoverVC?.preferredContentSize = CGSize(width: 284, height: 446)
//            popoverVC?.delegate = self
//            if let popoverController = popoverVC?.popoverPresentationController {
//                popoverController.sourceView = self.textColorSelectorView
//                popoverController.sourceRect = CGRect(x: 0, y: 0, width: 85, height: 30)
//                popoverController.delegate = self
//                present(popoverVC!, animated: true, completion: nil)
//            }
//        }
    }


}
