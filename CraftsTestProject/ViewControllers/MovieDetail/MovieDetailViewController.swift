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
    // MARK: - Outlets
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
    // MARK: - Variables
    let dateFormatter: DateFormatter = {
        $0.dateStyle = .medium
        $0.timeStyle = .none
        return $0
    }(DateFormatter())

    var movie: Movie? {
        didSet {
            configureView()
        }
    }

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureView()
    }

    // MARK: - Private methods
    private func configureView() {
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
            ]) { _ in
        }

        posterImageView.kf.setImage(with: movie.posterURL)
        titleLabel.text = movie.title ?? ""
        originalTitleLabel.text = movie.originalTitle != nil ? "\(movie.originalTitle!) (original title)" : ""
        releaseDateLabel.text = movie.releaseDate != nil ? dateFormatter.string(from: movie.releaseDate!) : ""
        synopsisLabel.text = movie.overview
        userRatingLabel.text = "⭐️ \(movie.voteAverage)/10"
        voteCountLabel.text = "(based on \(Double(movie.voteCount)) ratings)"
        popularityLabel.text = "\(movie.popularity)"

        likeButton.isSelected = movie.isMovieLiked()
        likeButton.backgroundColor = likeButton.isSelected ? .green : .lightGray
    }

    // MARK: - Actions
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        sender.pulsate()
        guard let movie = movie else { return }

        //Save or delete movie
        if movie.isMovieLiked() {
            movie.delete()
            sender.isSelected = false
        } else {
            movie.save()
            sender.isSelected = true
        }
        sender.backgroundColor = sender.isSelected ? .green : .lightGray
    }
}
