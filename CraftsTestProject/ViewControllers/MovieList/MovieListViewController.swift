//
//  MasterViewController.swift
//  CraftsTestProject
//
//  Created by Rafael Montilla on 7/18/19.
//  Copyright © 2019 RMontilla. All rights reserved.
//

import UIKit
import RealmSwift
import Toast_Swift
import RxSwift
import RxCocoa

class MovieListViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var movieCollectionView: UICollectionView!

    // MARK: - Variables
    private var detailViewController: MovieDetailViewController?
    private var likedMovies: Results<MovieObject>!
    private var viewModel = MovieListViewModel()
    private var disposeBag = DisposeBag()

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        initConfig()
        bindModel()
    }

    // MARK: - Private methods
    private func initConfig() {
        if let split = splitViewController {
            let controllers = split.viewControllers
            guard let navigationController = controllers[controllers.count-1] as? UINavigationController else { return }
            guard let detail = navigationController.topViewController as? MovieDetailViewController else { return }
            detailViewController = detail
            detailViewController?.delegate = self
        }
        let realm = try! Realm()
        likedMovies = realm.objects(MovieObject.self)
    }

    private func bindModel() {
        viewModel.errMessage
                 .subscribe(onNext: { [unowned self] message in
                    self.view.makeToast(message)
                 })
                 .disposed(by: disposeBag)

        viewModel.fetching
                 .subscribe(onNext: { [unowned self] fetching in
                    if fetching {
                        self.view.makeToastActivity(.bottom)
                    } else {
                        self.view.hideAllToasts(includeActivity: true, clearQueue: true)
                    }
                 })
                 .disposed(by: disposeBag)

        viewModel.firstMovie
                 .subscribe(onNext: { [unowned self] movie in
                    self.detailViewController?.movie = movie
                    self.detailViewController?.indexPath = IndexPath(row: 0, section: 0)
                 })
                 .disposed(by: disposeBag)

        segmentedControl.rx
                        .selectedSegmentIndex
                        .subscribe (onNext: {[unowned self] index in
                            guard let endpoint = Endpoint(index: index) else { return }
                            self.viewModel.movies.accept([])
                            self.viewModel.fetchMovieBatch(endpoint)
                        })
                        .disposed(by: disposeBag)

        bindCollectionView()
    }
    private func bindCollectionView() {

        movieCollectionView.register( UINib(nibName: Constants.Cells.movie, bundle: nil),
                                      forCellWithReuseIdentifier: Constants.Cells.movie)
        movieCollectionView.rx
                           .setDelegate(self)
                           .disposed(by: disposeBag)

        viewModel.movies
                 .bind(to: movieCollectionView.rx.items) { collectionView, row, movie in
                     guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Cells.movie,
                                                for: IndexPath(row: row, section: 0)) as? MovieCollectionViewCell
                                                else { return UICollectionViewCell()}
                     cell.configCell(withMovie: movie, isLiked: !self.likedMovies.filter { $0.id == movie.id }.isEmpty)
                     return cell
                 }
                 .disposed(by: disposeBag)
    }

    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.Segues.toDetail:
            guard let (movie, indexPath) = sender as? (Movie, IndexPath) else { return }
            guard let navigationController = segue.destination as? UINavigationController else { return }
            guard let detailViewController = navigationController.topViewController
                                             as? MovieDetailViewController else { return }
            detailViewController.movie = movie
            detailViewController.indexPath = indexPath
            detailViewController.delegate = self
        default: return
        }
    }
}

extension MovieListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = viewModel.movies.value[indexPath.row]
        if UI_USER_INTERFACE_IDIOM() == .pad {
            detailViewController?.movie = movie
            detailViewController?.indexPath = indexPath
        } else {
            performSegue(withIdentifier: Constants.Segues.toDetail, sender: (movie, indexPath))
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height - 40 && !viewModel.fetching.value {
            guard let endpoint = Endpoint(index: segmentedControl.selectedSegmentIndex) else { return }
            self.viewModel.fetchMovieBatch(endpoint)
        }
    }
}

extension MovieListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width/3
        let height = width * 1.5
        return CGSize(width: width, height: height)
    }
}

extension MovieListViewController: MovieDetailViewControllerDelegate {
    func detailViewController(detailView: MovieDetailViewController, modifiedMovieAtIndex indexPath: IndexPath) {
        movieCollectionView.reloadItems(at: [indexPath])
    }
}
