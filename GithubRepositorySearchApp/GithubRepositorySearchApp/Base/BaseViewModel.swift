//
//  BaseViewModel.swift
//  GithubRepositorySearchApp
//
//  Created by 박종우 on 2023/03/11.
//

import UIKit
import Combine

public enum BaseUILifeCycle {
    
    case viewDidLoad
    case viewWillAppear
    case viewDidAppear
    case viewWillDisappear
    case viewDidDisappear
}

public struct AlertModel {
    
    var title: String?
    
    var message: String?
    
    var buttons: [AlertButtonModel]
    
    struct AlertButtonModel {
        var buttonTitle: String
        
        var style: UIAlertAction.Style
        
        var buttonAction: ((UIAlertAction) -> Void)?
    }
}

public protocol BaseViewModel: AnyObject {
    
    associatedtype Model: Hashable
    
    var modelPublisher: PassthroughSubject<[Model], Never> { get }
    
    var alertPublisher: PassthroughSubject<AlertModel, Never> { get }
    
    func viewLifeCycleUpdate(_ lifeCycle: BaseUILifeCycle)
}
