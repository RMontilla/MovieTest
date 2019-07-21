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
import RxCocoa
import RxSwift
import RxRealm

protocol MovieDetailViewControllerDelegate: class {
    func detailViewController(detailView: MovieDetailViewController, modifiedMovieAtIndex indexPath: IndexPath)
}

class MovieDetailViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet var mainStackView: UIStackView!
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
    weak var delegate: MovieDetailViewControllerDelegate?
    var indexPath: IndexPath?
    var movie: Movie? {
        didSet {
            guard let movie = movie else { return }
            viewModel.movie.accept(movie)
        }
    }
    private var viewModel = MovieDetailViewModel()
    private var disposeBag = DisposeBag()

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViews()
        bindActions()
        if UI_USER_INTERFACE_IDIOM() == .phone {
            guard let movie = movie else { return }
            viewModel.movie.accept(movie)
        }
    }

    // MARK: - Private methods
    private func bindViews() {
        viewModel.title.bind(to: titleLabel.rx.text).disposed(by: disposeBag)
        viewModel.originalTitle.bind(to: originalTitleLabel.rx.text).disposed(by: disposeBag)
        viewModel.releaseDate.bind(to: releaseDateLabel.rx.text).disposed(by: disposeBag)
        viewModel.synopsis.bind(to: synopsisLabel.rx.text).disposed(by: disposeBag)
        viewModel.userRating.bind(to: userRatingLabel.rx.text).disposed(by: disposeBag)
        viewModel.voteCount.bind(to: voteCountLabel.rx.text).disposed(by: disposeBag)
        viewModel.popularity.bind(to: popularityLabel.rx.text).disposed(by: disposeBag)

        viewModel.posterURL
                 .subscribe(onNext: { [unowned self] url in
                     self.posterImageView.loadImageWithURL(url: url)
                 })
                 .disposed(by: disposeBag)
        viewModel.backdropURL
                 .subscribe(onNext: { [unowned self] url in
                     self.backdropImageView.loadImageWithURL(url: url)
                 })
                 .disposed(by: disposeBag)

        viewModel.movieID
                 .subscribe(onNext: { [unowned self] movieID in
                        self.mainStackView.isHidden = false
                        let realm = try! Realm()
                        let movie = realm.objects(MovieObject.self).filter("id == \(movieID)")
                        Observable.collection(from: movie).map { movies in
                             movies.count > 0
                        }.subscribe(onNext: { [unowned self] liked in
                            self.likeButton.isSelected = liked
                            self.likeButton.backgroundColor = liked ? Constants.Color.lightGreen : .lightGray
                        })
                        .disposed(by: self.disposeBag)
                 })
                 .disposed(by: disposeBag)
    }

    private func bindActions() {
        likeButton.rx
                  .tap
                  .subscribe(onNext: { [unowned self] _ in
                     self.likeButton.pulsate()
                     guard let movie = self.movie else { return }
                     guard let indexPath = self.indexPath else { return }
                     //Save or delete movie
                     if movie.isMovieLiked() {
                        movie.delete()
                     } else {
                        movie.save()
                     }
                     self.delegate?.detailViewController(detailView: self, modifiedMovieAtIndex: indexPath)
                  })
                  .disposed(by: self.disposeBag)
    }
}
