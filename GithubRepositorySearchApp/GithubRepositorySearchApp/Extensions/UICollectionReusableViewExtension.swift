//
//  UICollectionReusableViewExtension.swift
//  GithubRepositorySearchApp
//
//  Created by 박종우 on 2023/03/12.
//

import UIKit

extension UICollectionReusableView {
    
    public class var nib: UINib {
        UINib(nibName: Self.identifier, bundle: .main)
    }
    
    public class var identifier: String {
        String(describing: Self.self)
    }
}
