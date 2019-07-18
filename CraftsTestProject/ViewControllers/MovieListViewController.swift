//
//  MasterViewController.swift
//  CraftsTestProject
//
//  Created by Rafael Montilla on 7/18/19.
//  Copyright © 2019 RMontilla. All rights reserved.
//

import UIKit

class MovieListViewController: UIViewController {

    var detailViewController: MovieDetailViewController? = nil
    var objects = [Any]()


    override func viewDidLoad() {
        super.viewDidLoad()

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? MovieDetailViewController
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

