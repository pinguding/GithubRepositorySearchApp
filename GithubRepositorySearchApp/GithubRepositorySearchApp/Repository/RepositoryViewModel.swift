//
//  RepositoryViewModel.swift
//  GithubRepositorySearchApp
//
//  Created by 박종우 on 2023/03/13.
//

import Foundation
import Combine

final class RepositoryViewModel: BaseViewModel {
    
    typealias Model = URL
    
    var alertPublisher: PassthroughSubject<AlertModel, Never>
    
    var modelPublisher: CurrentValueSubject<[URL], Never>
    
    private let repositoryURL: URL?
    
    init(urlString: String) {
        
        alertPublisher = .init()
        modelPublisher = .init([])
        repositoryURL = URL(string: urlString)
    }
    
    func viewLifeCycleUpdate(_ lifeCycle: BaseUILifeCycle) {
        switch lifeCycle {
        case .viewDidLoad:
            if let url = repositoryURL {
                modelPublisher.send([url])
            } else {
                let alertModel = AlertModel(title: "잘못된 URL", message: "잘못된 형식의 URL 입니다.", buttons: [
                    .init(buttonTitle: "확인", style: .default)
                ])
                alertPublisher.send(alertModel)
            }
        default:
            return
        }
    }
}
