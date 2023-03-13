//
//  Network.swift
//  GithubRepositorySearchApp
//
//  Created by 박종우 on 2023/03/12.
//

import Foundation
import Combine

///URLSession 에서 사용할 HTTP Method 에 대한 get, post 에 대한 정의
public enum Method: String {
    case get = "GET"
    case post = "POST"
}

///API 호출에 사용되는 API Base URL 과 Path 에 대한 정의
public protocol APIItem {
    var baseURL: String { get }
    var path: String { get }
    var method: Method { get }
    var data: [String: String] { get }
    var headerFields: [String: String] { get }
}

///API 이용시 발생하는 Error 에 대한 정의와 각 Error 발생시에 화면에 띄워줄 UIAlertController 의 Message 정의
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

///API 호출에 사용될 Struct, 재사용을 위해 Generic 으로 API 를 생성하도록 개발함.
///Generic 을 이용한 이유는 호출하고 있는 API 에 대한 Path, Method, Parameter 를 직관적으로 알 수 있도록 하기위해 만듦
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
                
                guard let response = response as? HTTPURLResponse else {
                    promise(.failure(APIError.responseFail(-1)))
                    return
                }
                
                guard response.statusCode == 200 else {
                    if verbose { print("\(response.statusCode) Failure", "Response Data: \(String(data: data ?? Data(), encoding: .utf8) ?? "")") }
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
