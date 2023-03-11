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
        
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(sectionProvider: { [weak self] sectionIndex, environment in
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200)))
            
            let group = NSCollectionLayoutGroup.vertical(layoutSize: item.layoutSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
            if let enable = self?.viewModel?.enableActivityIndicator, enable {
                section.boundarySupplementaryItems = [
                    NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50)), elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
                ]
            }
            
            section.contentInsets = .init(top: 20, leading: 20, bottom: .zero, trailing: 20)
            section.interGroupSpacing = 20
            
            return section
        })
        
        collectionView.registerCells(SearchResultCell.self)
        collectionView.registerFooterView(ActivityIndicatorFooterView.self)
        
        dataSource = UICollectionViewDiffableDataSource<Int, Model>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            let baseCollectionView = collectionView as? BaseCollectionView
            
            return baseCollectionView?.dequeueReusableBaseCollectionCell(SearchResultCell.self, itemIdentifier: itemIdentifier, for: indexPath)
        })
        
        dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            let baseCollectionView = collectionView as? BaseCollectionView
            
            guard let self = self, let viewModel = self.viewModel else { return UICollectionReusableView() }
            
            return baseCollectionView?.dequeueReusableBaseSupplementaryView(ActivityIndicatorFooterView.self, kind: UICollectionView.elementKindSectionFooter, item: viewModel.enableActivityIndicator, for: indexPath)
        }
        
        collectionView.contentInset = .init(top: .zero, left: .zero, bottom: view.safeAreaInsets.bottom, right: .zero)
        
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            viewModel?.requestNextPage()
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, text.isEmpty == false else { return }
        viewModel?.requestAPI(item: DefaultGitHubSearchAPI(searchItem: text, page: 1))
    }
}
