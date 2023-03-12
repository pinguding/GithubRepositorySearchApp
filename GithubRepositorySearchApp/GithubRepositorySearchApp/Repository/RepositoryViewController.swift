//
//  RepositoryViewController.swift
//  GithubRepositorySearchApp
//
//  Created by 박종우 on 2023/03/13.
//

import UIKit
import WebKit

final class RepositoryViewController: BaseViewController<RepositoryViewModel> {
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Repository"
    }
    
    override func modelUpdateHandler(updatedItems: [URL]) {
        guard let url = updatedItems.first else { return }
        webView.load(URLRequest(url: url))
    }
}
