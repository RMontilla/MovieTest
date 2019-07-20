//
//  MasterViewController.swift
//  CraftsTestProject
//
//  Created by Rafael Montilla on 7/18/19.
//  Copyright © 2019 RMontilla. All rights reserved.
//

import UIKit
import MBProgressHUD

class MovieListViewController: BaseViewController {

    // MARK: - Outlets
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var movieCollectionView: UICollectionView!
    @IBOutlet var paginationLoadingDisplayView: UIView!

    // MARK: - Variables
    private let kCellIdentifier = "MovieCollectionViewCell"
    var detailViewController: MovieDetailViewController?
    var movies: [Movie]? {
        didSet {
            DispatchQueue.main.async {
                self.movieCollectionView.reloadData()
            }
        }
    }
    var refreshing = false

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        if let split = splitViewController {
            let controllers = split.viewControllers
            guard let navigationController = controllers[controllers.count-1] as? UINavigationController else { return }
            guard let detail = navigationController.topViewController as? MovieDetailViewController else { return }
            detailViewController = detail
        }
        movieCollectionView.register( UINib(nibName: kCellIdentifier, bundle: nil),
                                      forCellWithReuseIdentifier: kCellIdentifier)
        fetchMovieBatch()
    }

    // MARK: - Private methods
    private func fetchMovieBatch() {
        self.refreshing = true
        let page = ((movies?.count ?? 0)/20) + 1
        guard let endpoint = Endpoint(index: segmentedControl.selectedSegmentIndex) else { return }

        MBProgressHUD.showAdded(to: self.paginationLoadingDisplayView, animated: true)
        APIManager.shared.fetchMovies(endpoint: endpoint, page: page) { (result) in
            MBProgressHUD.hide(for: self.paginationLoadingDisplayView, animated: true)

            switch result {
            case .success(let newBatch):
                if self.movies != nil {
                    self.movies?.append(contentsOf: newBatch)
                } else {
                    self.movies = newBatch
                    if newBatch.count > 0 {
                        self.detailViewController?.movie = newBatch[0]
                    }
                }
            case .failure(let error):
                print("error \(error)")
            }
            self.refreshing = false
        }
    }

    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showDetail":
            guard let movie = sender as? Movie else { return }
            guard let navigationController = segue.destination as? UINavigationController else { return }
            guard let detailViewController = navigationController.topViewController
                                             as? MovieDetailViewController else { return }
            detailViewController.movie = movie
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
        return movies?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movie = movies![indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellIdentifier,
                         for: indexPath) as? MovieCollectionViewCell else { return UICollectionViewCell()}
        cell.configCell(withMovie: movie)
        return cell
    }
}

extension MovieListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movie = movies?[indexPath.row] else { return }
        if UI_USER_INTERFACE_IDIOM() == .pad {
            detailViewController?.movie = movie
        } else {
            performSegue(withIdentifier: "showDetail", sender: movie)
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
