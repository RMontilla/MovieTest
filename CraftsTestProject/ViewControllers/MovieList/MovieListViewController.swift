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

class MovieListViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var movieCollectionView: UICollectionView!
    @IBOutlet var paginationLoadingDisplayView: UIView!

    // MARK: - Variables
    var detailViewController: MovieDetailViewController?
    var movies: [Movie] = [Movie]() {
        didSet {
            DispatchQueue.main.async {
                self.movieCollectionView.reloadData()
            }
        }
    }
    var refreshing = false
    var likedMovies: Results<MovieObject>!

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        initConfig()
        fetchMovieBatch()
    }

    // MARK: - Private methods
    private func initConfig () {
        if let split = splitViewController {
            let controllers = split.viewControllers
            guard let navigationController = controllers[controllers.count-1] as? UINavigationController else { return }
            guard let detail = navigationController.topViewController as? MovieDetailViewController else { return }
            detailViewController = detail
            detailViewController?.delegate = self
        }
        movieCollectionView.register( UINib(nibName: Constants.Cells.movie, bundle: nil),
                                      forCellWithReuseIdentifier: Constants.Cells.movie)
        
        let realm = try! Realm()
        likedMovies = realm.objects(MovieObject.self)
    }
    
    private func fetchMovieBatch() {
        self.refreshing = true
        let page = (movies.count/20) + 1
        guard let endpoint = Endpoint(index: segmentedControl.selectedSegmentIndex) else { return }

        self.view.makeToastActivity(.bottom)
        APIManager.shared.fetchMovies(endpoint: endpoint, page: page) { (result) in
            self.view.hideAllToasts(includeActivity: true, clearQueue: true)

            switch result {
            case .success(let newBatch):
                if self.movies.isEmpty {
                    self.movies = newBatch
                    if newBatch.count > 0 {
                        self.detailViewController?.movie = newBatch[0]
                        self.detailViewController?.indexPath = IndexPath(row: 0, section: 0)
                    }
                } else {
                    self.movies.append(contentsOf: newBatch)
                }
                
            case .failure(let error):
                var errorMessage = ""
                switch error {
                case .apiError:
                    errorMessage = Constants.ErrMessage.apiError
                case .noData:
                    errorMessage = Constants.ErrMessage.noData
                case .serializationError:
                    errorMessage = Constants.ErrMessage.serializationError
                }
                self.view.makeToast(errorMessage)
            }
            self.refreshing = false
        }
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

    // MARK: - UISegmentedControl methods
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        movies = [Movie]()
        fetchMovieBatch()
    }
}

extension MovieListViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movie = movies[indexPath.row]
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Cells.movie,
                         for: indexPath) as? MovieCollectionViewCell else { return UICollectionViewCell()}
        cell.configCell(withMovie: movie, isLiked: !likedMovies.filter { $0.id == movie.id }.isEmpty)
        return cell
    }
}

extension MovieListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = movies[indexPath.row]
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
        if offsetY > contentHeight - scrollView.frame.height - 40 && !refreshing {
            fetchMovieBatch()
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
