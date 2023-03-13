//
//  UICollectionReusableViewExtension.swift
//  GithubRepositorySearchApp
//
//  Created by 박종우 on 2023/03/11.
//

import UIKit

open class BaseCollectionReusableView<Item: Hashable>: UICollectionReusableView {
    
    ///Generic 으로 등록된 아이템으로 ReusableView 를 Configuration 할 수 있는 함수
    open func configureReusableView(item: Item) {
        
    }
}

open class BaseCollectionViewCell<Item: Hashable>: UICollectionViewCell {
    
    ///Generic 으로 등록된 아이템으로 Cell 을 Configuration 할 수 있는 함수
    open func configureCell(item: Item) {
        
    }
}
