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

class MovieCollectionViewCell: UICollectionViewCell {
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var likeView: UIView!

    func configCell(withMovie movie: Movie, isLiked: Bool) {
        titleLabel.text = movie.title
        likeView.isHidden = !isLiked
        posterImageView.loadImageWithURL(url: movie.posterURL)
    }
}
