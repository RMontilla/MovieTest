//
//  MovieCollectionViewCell.swift
//  CraftsTestProject
//
//  Created by Rafael Montilla on 7/18/19.
//  Copyright © 2019 RMontilla. All rights reserved.
//

import Foundation
import UIKit

class MovieCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    func configCell(withMovie movie : Movie){
        self.posterImageView.image = UIImage(named: "")
        self.titleLabel.text = movie.title
    }
}
