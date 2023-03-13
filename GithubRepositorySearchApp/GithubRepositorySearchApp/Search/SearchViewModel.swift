//
//  SearchViewModel.swift
//  GithubRepositorySearchApp
//
//  Created by 박종우 on 2023/03/11.
//

import Foundation
import Combine
import Kingfisher

struct SearchResultModel: Hashable {
    var id: String = UUID().uuidString
    
    var title: String
    
    var avatarImageURLString: String
    
    var repositoryOwner: String
    
    var description: String
    
    var starCount: Int
    
    var language: String
    
    var languageColor: String
    
    var repositoryURLString: String
}

final class SearchViewModel: BaseViewModel {
    
    typealias Model = SearchResultModel
    
    var currentResultModel: [SearchResultModel] = []
    
    private var currentAPIItem: DefaultGitHubSearchAPI? = nil
    
    var modelPublisher: CurrentValueSubject<[SearchResultModel], Never> = .init([])
    
    var alertPublisher: PassthroughSubject<AlertModel, Never> = .init()
        
    var enableActivityIndicator: Bool = false
    
    private var cancellable: Set<AnyCancellable> = []
    
    private var totalCount: Int? = nil
    
    private let perPage: Int = 30
    
    deinit {
        cancellable.removeAll()
    }
    
    func viewLifeCycleUpdate(_ lifeCycle: BaseUILifeCycle) {
        switch lifeCycle {
        case .viewDidDisappear:
            removeImageCache()
        default:
            return
        }
    }
    
    func requestNextPage() {
        if let currentAPIItem = currentAPIItem, let totalCount = totalCount {
            if totalCount > currentAPIItem.currentPage * perPage {
                var newAPIItem = currentAPIItem
                newAPIItem.currentPage += 1
                requestAPI(item: newAPIItem, isNewItem: false)
            }
        }
    }
    
    func requestAPI<Item: APIItem>(item: Item, isNewItem: Bool = true) {
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
                guard let self = self else { return }
                self.currentAPIItem = item as? DefaultGitHubSearchAPI
                
                self.totalCount = response.totalCount
                let newModels = response.items
                    .map { githubItem -> SearchResultModel in
                        return SearchResultModel(title: githubItem.name, avatarImageURLString: githubItem.owner.avatarURL, repositoryOwner: githubItem.owner.login, description: githubItem.description ?? "", starCount: githubItem.starCount, language: githubItem.language ?? "", languageColor: "", repositoryURLString: githubItem.htmlUrl)
                    }
                if isNewItem {
                    if newModels.isEmpty {
                        self.alertPublisher.send(AlertModel(title: "검색 결과가 없습니다.", buttons: [.init(buttonTitle: "확인", style: .default)]))
                        self.enableActivityIndicator = false
                        self.modelPublisher.send([])
                        return
                    }
                    self.enableActivityIndicator = response.totalCount > newModels.count
                    self.modelPublisher.send(newModels)
                    
                } else {
                    self.enableActivityIndicator = response.totalCount > self.modelPublisher.value.count + newModels.count
                    self.modelPublisher.value.append(contentsOf: newModels)
                }
            }
            .store(in: &cancellable)
    }
    
    
    private func removeImageCache() {
        let cache = ImageCache.default
        
        cache.clearCache()
    }
}
