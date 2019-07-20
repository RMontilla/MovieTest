//
//  DetailViewController.swift
//  CraftsTestProject
//
//  Created by Rafael Montilla on 7/18/19.
//  Copyright © 2019 RMontilla. All rights reserved.
//

import UIKit
import Kingfisher
import RealmSwift

class MovieDetailViewController: BaseViewController {
    
    @IBOutlet var backdropImageView: UIImageView!
    @IBOutlet var posterImageView: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var originalTitleLabel: UILabel!
    @IBOutlet var releaseDateLabel: UILabel!
    @IBOutlet var synopsisLabel: UILabel!
    @IBOutlet var userRatingLabel: UILabel!
    @IBOutlet var voteCountLabel: UILabel!
    
    @IBOutlet var popularityLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    
    let dateFormatter: DateFormatter = {
        $0.dateStyle = .medium
        $0.timeStyle = .none
        return $0
    }(DateFormatter())
    
    var movie : Movie? {
        didSet {
            configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        guard let movie = movie else { return }
        guard let backdropImageView = self.backdropImageView else { return }
        
        let processor = DownsamplingImageProcessor(size: posterImageView.frame.size)
        backdropImageView.kf.indicatorType = .activity
        backdropImageView.kf.setImage(
            with: movie.backdropURL,
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
        
        posterImageView.kf.setImage(with: movie.posterURL)
        titleLabel.text = movie.title
        originalTitleLabel.text = "\(movie.originalTitle) (original title)"
        releaseDateLabel.text = dateFormatter.string(from: movie.releaseDate)
        synopsisLabel.text = movie.overview
        
        userRatingLabel.text = "⭐️ \(movie.voteAverage)/10"
        voteCountLabel.text = "(based on \(Double(movie.voteCount)) ratings)"
        popularityLabel.text = "\(movie.popularity)"
        
        
        let realm = try! Realm()
        let movieArray = realm.objects(Movie.self).filter { $0.id == movie.id}
        likeButton.isSelected = movieArray.count > 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureView()
    }

    @IBAction func likeButtonTapped(_ sender: UIButton) {
        
        sender.backgroundColor = sender.isSelected ? .green : .lightGray
        sender.pulsate()
        
        let realm = try! Realm()
        guard let movie = movie else { return }
        let movieArray = realm.objects(Movie.self).filter { $0.id == movie.id}
        
        if  movieArray.count > 0{
            let movieToRemove = movieArray[0]
            try! realm.write {
                realm.delete(movieToRemove)
            }
            sender.isSelected = false
        } else {
            try! realm.write {
                realm.add(movie)
            }
            sender.isSelected = true
        }
    }
}

