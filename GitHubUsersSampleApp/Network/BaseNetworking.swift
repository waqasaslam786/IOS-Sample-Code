//
//  BaseNetworking.swift
//  GitHubUsersSampleApp
//
//  Created by Khurram Bilal Nawaz on 06/03/2021.
//

import Foundation


enum AppError: Error {
    case NoDataAvailable
    case CanNotProcessData
    case ServerError
    case other
}

enum RequestType {
    case data
}

enum ResponseType {
    case json
}

enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

typealias Headers = [String: String]
typealias Parameters = [String : Any]


protocol Requestable {
}

extension Requestable {

    private func urlRequest(with method: RequestMethod, path: String, params: Parameters) -> URLRequest? {
        print("Requestable - urlRequest")
        guard let url = url(with: Global.shared.environment.baseURL, path: path, method: method, params: params ) else {
            print("Requestable - urlRequest - url is failing")
            return nil
        }
        
        print("Requestable - url \(url.absoluteString)")
        var request = URLRequest(url: url)

        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = Global.shared.environment.headers
        request.httpBody = getJSONBody(with: method, params: params)

        return request
    }

    private func url(with baseURL: String, path: String, method: RequestMethod, params: Parameters) -> URL? {
        print("Requestable - url - \(baseURL) -- \(path)")
        guard var urlComponents = URLComponents(url: URL.init(string: baseURL)!, resolvingAgainstBaseURL: false) else {
            print("Requestable - url - urlComponents is failing")
            return nil
        }
//        var urlComponents = URLComponents()
//        urlComponents.scheme = "https"
//        urlComponents.host = baseURL //"api.github.com"
        urlComponents.path = path
        urlComponents.queryItems = getQueryItems(with: method, params: params)
        return urlComponents.url
    }
    
    private func getQueryItems(with method: RequestMethod, params: Parameters) -> [URLQueryItem]? {
        guard method == .get else{
            return nil
        }
        return params.map { (key: String, value: Any) -> URLQueryItem in
            let valueString = (value as AnyObject).description
            return URLQueryItem(name: key, value: valueString)
        }
    }
    private func getJSONBody(with method: RequestMethod, params: Parameters) -> Data? {
        guard [.post, .put].contains(method) else {
            return nil
        }
        var jsonBody: Data?
        do {
            jsonBody = try JSONSerialization.data(withJSONObject: params,
                                                  options: .prettyPrinted)
        } catch {
            print(error)
        }
        return jsonBody
    }
    
    
    
}


extension Requestable {
    internal func getRequest(path: String, params: Parameters, callback: @escaping (Result<Any, AppError>) -> Void) {
        
        print("Requestable - getRequest ")
        request(method: .get, path: path, params: params, callback: callback)
    }

    internal func request(method: RequestMethod, path: String, params: Parameters, callback: @escaping (Result<Any, AppError>) -> Void ) {

        print("Requestable - request - before creating urlRequest")
        guard let urlRequest = urlRequest(with: method, path: path, params: params) else {
            print("Requestable - request - url")
            callback(.failure(.other))
            return
        }
        
        print("Requestable - request - before executing")
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Requestable - request - after executing \(error.localizedDescription)")
                    print(error.localizedDescription)
                    callback(.failure(error as! AppError))
                } else if let httpResponse = response as? HTTPURLResponse {
                    print("Requestable - request - after executing \(httpResponse.statusCode)")
                    if httpResponse.statusCode == 200 {
                        callback(.success(data!))
                    } else {
                        callback(.failure(.ServerError))
                    }
                }
            }
        }
        task.resume()
    }
}
