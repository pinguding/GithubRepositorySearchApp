//
//  Network.swift
//  GithubRepositorySearchApp
//
//  Created by 박종우 on 2023/03/12.
//

import Foundation
import Combine

public enum Method: String {
    case get = "GET"
    case post = "POST"
}

public protocol APIItem {
    var baseURL: String { get }
    var path: String { get }
    var method: Method { get }
    var data: [String: String] { get }
    var headerFields: [String: String] { get }
}

public enum APIError: Error {
    case wrongQuery
    case cannotConvertStringToURL
    case httpBodyEncodingFail
    case responseFail(Int?)
    case networkFail(Error)
    case nullResponseData
    case responseDataDecodingFail
    
    var alertMessage: String {
        switch self {
        case .wrongQuery, .cannotConvertStringToURL:
            return "Invalid URL"
        case .httpBodyEncodingFail:
            return "Request fail. Invalid data format"
        case .responseFail(let code):
            return "Response fail: Code - \(code ?? 0)"
        case .networkFail:
            return "Network connection lost"
        case .nullResponseData, .responseDataDecodingFail:
            return "Invalid data type was received"
        }
    }
}

public struct API<Item: APIItem> {

    ///Request API, Response Data 를 디코딩해줄 data type 을 responseDataType 에 넣어준다. 네트워크 결과를 콘솔에서 확인하고 싶을때는 verbose 를 true로, default 는 false
    ///API Method 가 Get 이면 APIItem 의 Parameter 는 Query 로, Post 면 httpBody 로 인코딩해서 들어감
    func request<ResponseData: Codable>(item: Item, responseDataType: ResponseData.Type, verbose: Bool = false) -> Future<ResponseData, Error> {
        return Future { promise in
            guard var url = URL(string: item.baseURL + item.path) else {
                if verbose { print(item.baseURL + item.path, APIError.cannotConvertStringToURL) }
                promise(.failure(APIError.cannotConvertStringToURL))
                return
            }

            if item.method == .get {
                var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
                var queryItems: [URLQueryItem] = []
                item.data.forEach {
                    queryItems.append(URLQueryItem(name: $0.key, value: $0.value))
                }
                urlComponents?.queryItems = queryItems
                guard let queryContainedURL = urlComponents?.url else {
                    if verbose { print(item.data, APIError.wrongQuery) }
                    promise(.failure(APIError.wrongQuery))
                    return
                }
                url = queryContainedURL
            }

            var urlRequest = URLRequest(url: url)
            if item.method == .post {
                guard let data = try? JSONEncoder().encode(item.data) else {
                    if verbose { print(item.data, APIError.httpBodyEncodingFail) }
                    promise(.failure(APIError.httpBodyEncodingFail))
                    return
                }
                urlRequest.httpBody = data
            }

            urlRequest.httpMethod = item.method.rawValue

            item.headerFields.forEach {
                urlRequest.addValue($0.value, forHTTPHeaderField: $0.key)
            }
            
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    if verbose { print("NETWORK ERROR", APIError.networkFail(error), error.localizedDescription) }
                    promise(.failure(APIError.networkFail(error)))
                    return
                }
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    promise(.failure(APIError.responseFail(nil)))
                    return
                }
                
                guard response.statusCode == 200 else {
                    promise(.failure(APIError.responseFail(response.statusCode)))
                    return
                }
                
                guard let data = data else {
                    if verbose { print("NO DATA", APIError.nullResponseData) }
                    promise(.failure(APIError.nullResponseData))
                    return
                }
                
                if verbose { print(String(data: data, encoding: .utf8) as Any) }
                
                guard let result = try? JSONDecoder().decode(ResponseData.self, from: data) else {
                    if verbose { print("Decoding Fail", APIError.responseDataDecodingFail) }
                    promise(.failure(APIError.responseDataDecodingFail))
                    return
                }
                
                promise(.success(result))
                
            }.resume()
        }
    }
}
