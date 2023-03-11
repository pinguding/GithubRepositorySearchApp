//
//  UICollectionReusableViewExtension.swift
//  GithubRepositorySearchApp
//
//  Created by 박종우 on 2023/03/11.
//

import UIKit

open class BaseCollectionReusableView<Item: Hashable>: UICollectionReusableView {
    
    open func configureReusableView(item: Item) {
        
    }
}

open class BaseCollectionViewCell<Item: Hashable>: UICollectionViewCell {
    
    open func configureCell(item: Item) {
        
    }
}
