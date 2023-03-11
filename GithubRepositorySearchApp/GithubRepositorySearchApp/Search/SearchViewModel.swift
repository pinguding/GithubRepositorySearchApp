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
    
    var avatarImageURLString: String
    
    var repositoryOwner: String
    
    var description: String
    
    var imageCount: Int
    
    var language: String
    
    var languageColor: String
}

final class SearchViewModel: BaseViewModel {
    
    typealias Model = SearchResultModel
    
    var currentResultModel: [SearchResultModel] = []
    
    private var currentAPIItem: DefaultGitHubSearchAPI? = nil
    
    var modelPublisher: CurrentValueSubject<[SearchResultModel], Never> = .init([])
    
    var alertPublisher: PassthroughSubject<AlertModel, Never> = .init()
    
    var apiItemPublisher: PassthroughSubject<DefaultGitHubSearchAPI, Never> = .init()
    
    var enableActivityIndicator: Bool = false
    
    private var cancellable: Set<AnyCancellable> = []
    
    init() {
        apiItemPublisher
            .sink { [weak self] apiItem in
                self?.requestAPI(item: apiItem)
            }
            .store(in: &cancellable)
    }
    
    deinit {
        cancellable.removeAll()
    }
    
    func viewLifeCycleUpdate(_ lifeCycle: BaseUILifeCycle) { }
    
    func updateCurrentAPIItem(item: DefaultGitHubSearchAPI, toNextPage: Bool) {
        if let currentAPIItem = currentAPIItem, toNextPage {
            
        }
    }
    
    func requestAPI<Item: APIItem>(item: Item) {
        let useCase = API<Item>()
        useCase.request(item: item, responseDataType: GitHubResponseData.self)
            .sink { [weak self] completion in
                switch completion {
                case let .failure(error):
                    var messageString: String? = nil
                    if let error = error as? APIError {
                        messageString = error.alertMessage
                    }
                    self?.alertPublisher.send(AlertModel.networkDefaultModel(message: messageString))
                case .finished:
                    break
                }
            } receiveValue: { [weak self] response in
                self?.currentAPIItem = item as? DefaultGitHubSearchAPI
                let newModels = response.items
                    .map { githubItem -> SearchResultModel in
                        return SearchResultModel(title: githubItem.name, avatarImageURLString: githubItem.owner.avatarURL, repositoryOwner: githubItem.owner.login, description: githubItem.description ?? "", imageCount: githubItem.starCount, language: githubItem.language ?? "", languageColor: "")
                    }
                self?.modelPublisher.value.append(contentsOf: newModels)
            }
            .store(in: &cancellable)
    }
}
