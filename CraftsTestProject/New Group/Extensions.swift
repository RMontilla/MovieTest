//
//  Extensions.swift
//  CraftsTestProject
//
//  Created by Rafael Montilla on 7/19/19.
//  Copyright © 2019 RMontilla. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

extension UIImageView {
    func loadImageWithURL (url: URL) {
        let processor = DownsamplingImageProcessor(size: self.frame.size)
        self.kf.indicatorType = .activity
        if let activityView = self.kf.indicator?.view as? UIActivityIndicatorView {
            activityView.color = .white
        }
        self.kf.setImage(
            with: url,
            placeholder: nil,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
        ]) { _ in
        }
    }
}

extension UIButton {
    func pulsate() {
        UIButton.animate(withDuration: 0.2,
                         animations: {
                            self.transform = CGAffineTransform(scaleX: 0.975, y: 0.96)
        },
                         completion: { _ in
                            UIButton.animate(withDuration: 0.2, animations: {
                                self.transform = CGAffineTransform.identity
                            })
        })
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

@IBDesignable class GradientView: UIView {
    @IBInspectable var topColor: UIColor = .white
    @IBInspectable var bottomColor: UIColor = .black
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        guard let layer = layer as? CAGradientLayer else { return }
        layer.colors = [topColor.cgColor, bottomColor.cgColor]
    }
}
