//
//  ViewController.swift
//  GithubRepositorySearchApp
//
//  Created by 박종우 on 2023/03/11.
//

import UIKit

final class SearchViewController: BaseViewController<SearchViewModel> {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, Model>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.title = "Search Repository"
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, environment in
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)))
            
            item.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
            
            let group = NSCollectionLayoutGroup.vertical(layoutSize: item.layoutSize, subitems: [item])
            
            return NSCollectionLayoutSection(group: group)
        })
        
        dataSource = UICollectionViewDiffableDataSource<Int, Model>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            
            return UICollectionViewCell()
        })
    }
    
    override func modelUpdateHandler(updatedItems: [Model]) {
        var snapShot = NSDiffableDataSourceSnapshot<Int, Model>()
        snapShot.appendSections([0])
        snapShot.appendItems(updatedItems)
        dataSource?.apply(snapShot)
    }
    
    
    private func registerCells() {
        
    }
}

extension SearchViewController: UICollectionViewDelegate {
    
    
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
}
