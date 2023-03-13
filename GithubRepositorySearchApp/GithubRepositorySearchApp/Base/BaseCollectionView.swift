//
//  UICollectionViewExtension.swift
//  GithubRepositorySearchApp
//
//  Created by 박종우 on 2023/03/12.
//

import UIKit

open class BaseCollectionView: UICollectionView {
    
    ///Cell 을 간편하게 등록하기 위한 로직
    func registerCells(_ cellTypes: UICollectionViewCell.Type...) {
        cellTypes.forEach { cellType in
            self.register(cellType.nib, forCellWithReuseIdentifier: cellType.identifier)
        }
    }
    
    ///Supplementary View 중 HeaderView 를 등록하기 위한 로직
    ///Kind 로 구분하지 않은 이유는 직관적으로 함수이름을 보고 등록하기 편하게 하기 위해서 만듦
    func registerHeaderView(_ headerViews: UICollectionReusableView.Type...) {
        headerViews.forEach { headerType in
            self.register(headerType.nib, forSupplementaryViewOfKind: Self.elementKindSectionHeader, withReuseIdentifier: headerType.identifier)
        }
    }
    
    ///Supplementary View 중 FooterView 를 등록하기 위한 로직
    func registerFooterView(_ footerViews: UICollectionReusableView.Type...) {
        footerViews.forEach { footerType in
            self.register(footerType.nib, forSupplementaryViewOfKind: Self.elementKindSectionFooter, withReuseIdentifier: footerType.identifier)
        }
    }
    
    ///BaseCollectionViewCell 은 공통적으로 configureCell 을 포함하고 있기 떄문에 BaseCollectionView 와 BaseCollectionViewCell 을 이용할때 간편하게 cell 에 대한 configuration 을 할 수 있도록 설계함
    func dequeueReusableBaseCollectionCell<Cell, Item>(_ cell: Cell.Type, itemIdentifier: Item, for indexPath: IndexPath) -> Cell where Cell: BaseCollectionViewCell<Item>, Item: Hashable {
        let cell = dequeueReusableCell(withReuseIdentifier: cell.identifier, for: indexPath) as! Cell
        cell.configureCell(item: itemIdentifier)
        return cell
    }
    
    ///BaseCollectionReusableView 는 공통적으로 configureReusableView 를 포함하고 있기 때문에 BaseCollectionView 와 BaseCollectionReusableView 를 이용한때 간편하게 Reusable View 에 대한 configuration 을 할 수 있도록 설계함
    func dequeueReusableBaseSupplementaryView<View, Item>(_ view: View.Type, kind: String, item: Item, for indexPath: IndexPath) -> View where View: BaseCollectionReusableView<Item>, Item: Hashable {
        let cell = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: view.identifier, for: indexPath) as! View
        cell.configureReusableView(item: item)
        return cell
    }
}
