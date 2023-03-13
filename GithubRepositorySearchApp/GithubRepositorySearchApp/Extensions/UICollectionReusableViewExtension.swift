//
//  UICollectionReusableViewExtension.swift
//  GithubRepositorySearchApp
//
//  Created by 박종우 on 2023/03/12.
//

import UIKit

extension UICollectionReusableView {
    ///UICollectionView 에 Register 할때 쉽게 등록할 수 있도록 UINib 에 대한 정보 저장. 해당 변수를 이용한 register 를 할때 반드시 UINib file 명은 Class 이름과 같아야한다.
    public class var nib: UINib {
        UINib(nibName: Self.identifier, bundle: .main)
    }
    
    ///UICollectionView 에 Register 할때 쉽게 등록할 수 있도록 identifier 에 대한 정보 저장. 해당 변수를 이용한 register 를 할때 반드시 identifier은 Class 이름과 같아야한다.
    public class var identifier: String {
        String(describing: Self.self)
    }
}
