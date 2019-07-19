//
//  MovieCollectionViewCell.swift
//  CraftsTestProject
//
//  Created by Rafael Montilla on 7/18/19.
//  Copyright © 2019 RMontilla. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class MovieCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    func configCell(withMovie movie : Movie){
        
        titleLabel.text = movie.title
        //self.posterImageView.kf.setImage(with: movie.posterURL)
        
        let url = movie.posterURL
        let processor = DownsamplingImageProcessor(size: posterImageView.frame.size)
        posterImageView.kf.indicatorType = .activity
        posterImageView.kf.setImage(
            with: url,
            placeholder: nil,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        {
            result in
        }
    }
}
