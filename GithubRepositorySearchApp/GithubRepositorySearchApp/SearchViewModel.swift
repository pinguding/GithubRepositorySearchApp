//
//  SearchViewModel.swift
//  GithubRepositorySearchApp
//
//  Created by 박종우 on 2023/03/11.
//

import Foundation
import Combine

struct SearchResultModel: Hashable {
    var id: String = UUID().uuidString
    
    var title: String
    
    var logoImageURLString: String
    
    var logoTitle: String
    
    var description: String
    
    var imageCount: Int
    
    var language: String
    
    var languageColor: String
}

final class SearchViewModel: BaseViewModel {
    
    typealias Model = SearchResultModel
    
    var modelPublisher: PassthroughSubject<[SearchResultModel], Never> = .init()
    
    var alertPublisher: PassthroughSubject<AlertModel, Never> = .init()
    
    func viewLifeCycleUpdate(_ lifeCycle: BaseUILifeCycle) { }
    
}
