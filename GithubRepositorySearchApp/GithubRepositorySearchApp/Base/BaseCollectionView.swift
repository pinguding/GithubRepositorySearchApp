//
//  UICollectionViewExtension.swift
//  GithubRepositorySearchApp
//
//  Created by 박종우 on 2023/03/12.
//

import UIKit

open class BaseCollectionView: UICollectionView {
    
    func registerCells(_ cellTypes: UICollectionViewCell.Type...) {
        cellTypes.forEach { cellType in
            self.register(cellType.nib, forCellWithReuseIdentifier: cellType.identifier)
        }
    }
    
    func registerHeaderView(_ headerViews: UICollectionReusableView.Type...) {
        headerViews.forEach { headerType in
            self.register(headerType.nib, forSupplementaryViewOfKind: Self.elementKindSectionHeader, withReuseIdentifier: headerType.identifier)
        }
    }
    
    func registerFooterView(_ footerViews: UICollectionReusableView.Type...) {
        footerViews.forEach { footerType in
            self.register(footerType.nib, forSupplementaryViewOfKind: Self.elementKindSectionFooter, withReuseIdentifier: footerType.identifier)
        }
    }
    
    func dequeueReusableBaseCollectionCell<Cell, Item>(_ cell: Cell.Type, itemIdentifier: Item, for indexPath: IndexPath) -> Cell where Cell: BaseCollectionViewCell<Item>, Item: Hashable {
        let cell = dequeueReusableCell(withReuseIdentifier: cell.identifier, for: indexPath) as! Cell
        cell.configureCell(item: itemIdentifier)
        return cell
    }
}
