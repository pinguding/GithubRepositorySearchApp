//
//  ActivityIndicatorFooterView.swift
//  GithubRepositorySearchApp
//
//  Created by 박종우 on 2023/03/12.
//

import UIKit

final class ActivityIndicatorFooterView: BaseCollectionReusableView<Bool> {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func configureReusableView(item: Bool) {
        if item {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}
