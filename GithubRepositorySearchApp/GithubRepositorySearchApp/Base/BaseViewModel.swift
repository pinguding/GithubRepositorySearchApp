//
//  BaseViewModel.swift
//  GithubRepositorySearchApp
//
//  Created by 박종우 on 2023/03/11.
//

import UIKit
import Combine

///ViewModel 에서 각각의 UILifeCycle 에서 별도로 진행할 비즈니스 로직이 있는 경우 해당 enum을 이용해 ViewModel 의 viewLifeCycle function 에서 구현
public enum BaseUILifeCycle {
    
    case viewDidLoad
    case viewWillAppear
    case viewDidAppear
    case viewWillDisappear
    case viewDidDisappear
}

///ViewController 에서 띄울 AlertController 에 대한 정보
public struct AlertModel {
    
    var title: String?
    
    var message: String?
    
    var buttons: [AlertButtonModel]
    
    struct AlertButtonModel {
        var buttonTitle: String
        
        var style: UIAlertAction.Style
        
        var buttonAction: ((UIAlertAction) -> Void)?
    }
    
    ///Network 에서 기본으로 사용되는 Model 을 생성하는 함수를 static 으로 선언하여 간편하게 사용할 수 있도록 함.
    static func networkDefaultModel(message: String?) -> AlertModel {
        return AlertModel(title: "네트워크 오류", message: message, buttons: [
            AlertButtonModel(buttonTitle: "확인", style: .default)
        ])
    }
}

///ViewModel 에 대한 정의가 포함된 Protocol
public protocol BaseViewModel: AnyObject {
    
    ///ViewModel 에서 View 를 Update 할 때 사용할 Model 에 대한 associatedtype
    associatedtype Model: Hashable
    
    ///View에 Model 을 전달하는 Publisher
    var modelPublisher: CurrentValueSubject<[Model], Never> { get }
    
    ///ViewModel 에서 Alert 를 띄울 때 사용하는 publisher
    var alertPublisher: PassthroughSubject<AlertModel, Never> { get }
    
    ///UILifeCycle 별로 비즈니스 로직을 선언할 때 사용되는 함수
    func viewLifeCycle(_ lifeCycle: BaseUILifeCycle)
}
