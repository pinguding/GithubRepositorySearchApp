//
//  ViewController.swift
//  GithubRepositorySearchApp
//
//  Created by 박종우 on 2023/03/11.
//

import UIKit
import Kingfisher

final class SearchViewController: BaseViewController<SearchViewModel> {

    @IBOutlet weak var collectionView: BaseCollectionView!
    
    ///SearchViewController 에서 사용하는 UICollectionView의 UICollectionViewDiffableDataSource
    private var dataSource: UICollectionViewDiffableDataSource<Int, Model>?
    
    ///Main.storyboard 에서 바로 RootViewController 로 initailize 되기 때문에 Storyboard 로 initailize 되는 required init?(coder: NSCoder) 에서 viewModel 을 생성함
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        viewModel = SearchViewModel()
    }
    
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
        
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            let baseCollectionView = collectionView as? BaseCollectionView
            
            guard let viewModel = self.viewModel else { return UICollectionReusableView() }
            
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
        searchController.searchBar.delegate = self
        ///obscuresBackgroundDuringPresentation = false 로 지정한 이유는 searchResultController 를 이용하고 있지않고 해당 부분을 true 로 두면 iOS 13 에서
        ///searchController 의 searchBar 가 first responder 가 되었을때 obsecure 한 layer 가 생기고 해당 layer 때문에 SearhViewController 의 Control 이 적용되지 않아 필수로 지정해야함
        searchController.obscuresBackgroundDuringPresentation = false
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}

extension SearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        ///ActivityIndicator Footer View 가 보여지게 될때 그다음 Page 에 대한 request 를 보낸다.
        if elementKind == UICollectionView.elementKindSectionFooter {
            viewModel?.requestNextPage()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let urlString = viewModel?.modelPublisher.value[indexPath.item].repositoryURLString else {
            return
        }
        ///셀을 선택할 시 Github Repository URL 을 이용해 WebView 를 통해 보여준다.
        let repositoryViewController = RepositoryViewController.build(viewModel: RepositoryViewModel(urlString: urlString))
        navigationController?.pushViewController(repositoryViewController, animated: true)
    }
}

extension SearchViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, text.isEmpty == false else { return }
        viewModel?.requestAPI(item: DefaultGitHubSearchAPI(searchItem: text, page: 1))
    }
}
