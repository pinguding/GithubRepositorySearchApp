//
//  GithubAPIItem.swift
//  GithubRepositorySearchApp
//
//  Created by 박종우 on 2023/03/12.
//

import Foundation

struct DefaultGitHubSearchAPI: APIItem {
    
    init(searchItem: String, page: Int) {
        currentPage = page
        data = [
            "q": searchItem,
            "page": "\(page)"
        ]
    }
    
    var currentPage: Int {
        didSet {
            data["page"] = "\(currentPage)"
        }
    }
    
    var baseURL: String = "https://api.github.com"
    
    var path: String = "/search/repositories"
    
    var method: Method = .get
    
    var data: [String : String] = [:]
    
    var headerFields: [String : String] = [
        "accept" : "application/vnd.github+json"
    ]
}


struct GitHubResponseData: Codable {
    
    var totalCount: Int
    
    var items: [GithubItem]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
}

struct GithubItem: Codable {
    var id: Int
    
    var name: String
    
    var owner: GithubOwnerData
    
    var starCount: Int
    
    var language: String?
    
    var description: String?
    
    var htmlUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case owner
        case starCount = "stargazers_count"
        case language
        case description
        case htmlUrl = "html_url"
    }
}

struct GithubOwnerData: Codable {
    
    var avatarURL: String
    
    var login: String
    
    enum CodingKeys: String, CodingKey {
        case avatarURL = "avatar_url"
        case login
    }
}
