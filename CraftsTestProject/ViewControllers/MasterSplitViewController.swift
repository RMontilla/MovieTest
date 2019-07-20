//
//  MasterSplitViewController.swift
//  CraftsTestProject
//
//  Created by Rafael Montilla on 7/20/19.
//  Copyright © 2019 RMontilla. All rights reserved.
//

import Foundation
import UIKit

class MasterSplitViewController :UISplitViewController, UISplitViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.preferredDisplayMode = .allVisible
    }
    
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController) -> Bool {
        // Return true to prevent UIKit from applying its default behavior
        return true
    }
    
}
