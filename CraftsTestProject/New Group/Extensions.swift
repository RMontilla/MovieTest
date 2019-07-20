//
//  Extensions.swift
//  CraftsTestProject
//
//  Created by Rafael Montilla on 7/19/19.
//  Copyright © 2019 RMontilla. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class GradientView: UIView {
    @IBInspectable var topColor: UIColor = UIColor.white
    @IBInspectable var bottomColor: UIColor = UIColor.black

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    override func layoutSubviews() {
        guard let layer = layer as? CAGradientLayer else { return }
        layer.colors = [topColor.cgColor, bottomColor.cgColor]
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
