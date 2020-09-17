//
//  SPSlidePhotoView.swift
//  SlidePhoto
//
//  Created by VictorZhang on 2020/9/5.
//  Copyright © 2020 VictorZhang. All rights reserved.
//

import UIKit
import SDWebImage


@objc(SPSlidePhotoItemView)
class SPSlidePhotoItemView: UIView {

    private let imageView = UIImageView()
    private let textLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews(frame: frame)
        
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true
        
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
        
        /*
        // 设置阴影
        self.layer.contentsScale = UIScreen.main.scale
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 6.0
        self.layer.shadowOffset = CGSize(width: 10, height: 10)
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        //self.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.bounds].CGPath;
        self.layer.shouldRasterize = true // 设置缓存
        self.layer.rasterizationScale = UIScreen.main.scale // 设置抗锯齿边缘
         */
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(frame: CGRect) {
        let screenSize = frame.size
        let imageHeight = screenSize.height * 0.8
        let textHeight = screenSize.height * 0.2
        //let imageViewHeight: CGFloat = 260
         
        let imageBGView = UIView()
        imageBGView.backgroundColor = self.applyRandomColorToBackgroundView()
        self.addSubview(imageBGView)
        imageBGView.snp.makeConstraints {
            $0.left.top.right.equalToSuperview()
            $0.height.equalTo(imageHeight)
        }
        
        //imageView.layer.cornerRadius = imageViewHeight / 2
        //imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageBGView.addSubview(imageView)
        imageView.snp.makeConstraints {
            //$0.width.height.equalTo(imageViewHeight)
            //$0.centerX.equalToSuperview()
            //$0.centerY.equalToSuperview()
            $0.edges.equalToSuperview()
        }
        
        let textBGView = UIView()
        textBGView.backgroundColor = UIColor.white
        self.addSubview(textBGView)
        textBGView.snp.makeConstraints {
            $0.height.equalTo(textHeight)
            $0.left.bottom.right.equalToSuperview()
        }
        
        textLabel.textAlignment = .center
        textLabel.textColor = UIColor.black
        textLabel.font = UIFont.systemFont(ofSize: 16)
        textLabel.numberOfLines = 0
        textBGView.addSubview(textLabel)
        textLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.left.equalTo(10)
            $0.right.equalTo(-10)
        }
        
    }
    
    private func applyRandomColorToBackgroundView() -> UIColor {
        // 设置随机背景颜色
        let colorPairs = [ UIColor(rgb: 0xFAD961), UIColor(rgb: 0xF76B1C),
                           UIColor(rgb: 0xffcc33), UIColor(rgb: 0x663333),
                           UIColor(rgb: 0xEEE685), UIColor(rgb: 0xEE9A00),
                           UIColor(rgb: 0xFFA07A), UIColor(rgb: 0xD2691E),
                           UIColor(rgb: 0xFF8C69), UIColor(rgb: 0x6699ff),
                        ]
        let randomNumber = Int.random(in: 0..<colorPairs.count)
        return colorPairs[randomNumber]
    }
    
    @objc public func updateData(with model: SPImageCardDataModel) {
        if let imageUrl = model.thumb {
            
            // 使用SDWebImage的图片下载器
            //self.imageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: nil, options: .progressiveLoad, completed: nil)
            //self.imageView.sp_showImage(with: URL(string: imageUrl))
            
            // 自己开发的图片简单下载器
            self.imageView.sp_showImage(with: URL(string: imageUrl)) { _,_ in }
        }
        
        self.textLabel.text = model.title
    }

}
