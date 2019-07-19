//
//  MasterViewController.swift
//  CraftsTestProject
//
//  Created by Rafael Montilla on 7/18/19.
//  Copyright © 2019 RMontilla. All rights reserved.
//

import UIKit

class MovieListViewController: UIViewController {
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var movieCollectionView: UICollectionView!
    
    private let kCellIdentifier = "MovieCollectionViewCell"
    
    var detailViewController: MovieDetailViewController? = nil
    var movies : [Movie]? {
        didSet {
            movieCollectionView.reloadData()
        }
    }
    
    var refreshing = false


    override func viewDidLoad() {
        super.viewDidLoad()

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? MovieDetailViewController
        }
        
        movieCollectionView.register( UINib(nibName: kCellIdentifier, bundle: nil), forCellWithReuseIdentifier: kCellIdentifier)
        
        fetchMovieBatch()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .white
    }
    
    func fetchMovieBatch (){
        self.refreshing = true
        let page = ((movies?.count ?? 0)/20) + 1
        guard let endpoint = Endpoint(index: segmentedControl.selectedSegmentIndex) else { return }
        
        APIManager.shared.fetchMovies(endpoint: endpoint, page: page) { (result) in
            
            switch result {
            case .success(let newBatch):
                
                if self.movies != nil {
                    self.movies?.append(contentsOf: newBatch)
                } else {
                    self.movies = newBatch
                }
                
            case .failure(let error):
                print("error \(error)")
            }
            
            self.refreshing = false
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        //clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showDetail":
            
            guard let cell = sender as? UICollectionViewCell else { return }
            guard let indexPath = self.movieCollectionView!.indexPath(for: cell) else { return }
            guard let movie = movies?[indexPath.row] else { return }
            guard let detailViewController = (segue.destination as! UINavigationController).topViewController as? MovieDetailViewController else { return }
            detailViewController.movie = movie
            
        default: return
        }
    }
    
    //MARK : - UISegmentedControl methods
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        movies = [Movie]()
        fetchMovieBatch()
    }
}

extension MovieListViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let movie = movies![indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellIdentifier, for: indexPath) as! MovieCollectionViewCell
        cell.configCell(withMovie: movie)
        return cell
    }
}

extension MovieListViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        performSegue(withIdentifier: "showDetail", sender: cell)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height && !refreshing {
            fetchMovieBatch()
        }
    }

}

extension MovieListViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width/3
        let height = width * 1.5
        return CGSize(width: width , height: height)
    }
}

