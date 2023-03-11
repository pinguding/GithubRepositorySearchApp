//
//  ViewController.swift
//  GithubRepositorySearchApp
//
//  Created by 박종우 on 2023/03/11.
//

import UIKit

final class SearchViewController: BaseViewController<SearchViewModel> {

    @IBOutlet weak var collectionView: BaseCollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, Model>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavitaionBar()
        
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, environment in
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)))
            
            item.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
            
            let group = NSCollectionLayoutGroup.vertical(layoutSize: item.layoutSize, subitems: [item])
            
            return NSCollectionLayoutSection(group: group)
        })
        
        collectionView.registerCells(SearchResultCell.self)
        
        dataSource = UICollectionViewDiffableDataSource<Int, Model>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            let baseCollectionView = collectionView as? BaseCollectionView
            
            return baseCollectionView?.dequeueReusableBaseCollectionCell(SearchResultCell.self, itemIdentifier: itemIdentifier, for: indexPath)
        })
    }
    
    override func modelUpdateHandler(updatedItems: [Model]) {
        var snapShot = NSDiffableDataSourceSnapshot<Int, Model>()
        snapShot.appendSections([0])
        snapShot.appendItems(updatedItems)
        dataSource?.apply(snapShot)
    }
    
    
    private func setupNavitaionBar() {
        navigationItem.title = "Search Repository"
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }
}

extension SearchViewController: UICollectionViewDelegate {
    
    
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
}
