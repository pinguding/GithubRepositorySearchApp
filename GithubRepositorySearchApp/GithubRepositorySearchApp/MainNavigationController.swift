//
//  MainNavigationController.swift
//  GithubRepositorySearchApp
//
//  Created by 박종우 on 2023/03/11.
//

import UIKit

final class MainNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pushViewController(SearchViewController.build(viewModel: SearchViewModel()), animated: false)
        
    }
}
