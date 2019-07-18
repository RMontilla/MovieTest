//
//  MasterViewController.swift
//  CraftsTestProject
//
//  Created by Rafael Montilla on 7/18/19.
//  Copyright © 2019 RMontilla. All rights reserved.
//

import UIKit

class MovieListViewController: UIViewController, UICollectionViewDelegate {
    

    @IBOutlet var movieCollectionView: UICollectionView!
    
    private let kCellIdentifier = "MovieCollectionViewCell"
    
    var detailViewController: MovieDetailViewController? = nil
    var movies : [Movie]? {
        didSet {
            movieCollectionView.reloadData()
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? MovieDetailViewController
        }
        
        movieCollectionView.register( UINib(nibName: kCellIdentifier, bundle: nil), forCellWithReuseIdentifier: kCellIdentifier)
        
        APIManager.shared.fetchMovies { (result) in
            
            switch result {
            case .success(let movies):
                self.movies = movies
            case .failure(let error):
                    print("error \(error)")
            }
            
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        //clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            //if let indexPath = tableView.indexPathForSelectedRow {
                /*let object = objects[0] as! NSDate
                let controller = (segue.destination as! UINavigationController).topViewController as! MovieDetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true*/
            //}
        }
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

extension MovieListViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width/3
        let height = width * 1.8
        return CGSize(width: width , height: height)
    }
}

