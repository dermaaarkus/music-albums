//
//  Webservice.swift
//  MusicAlbums
//
//  Created by Markus Faßbender on 15.06.19.
//

import UIKit

public final class Webservice: NSObject {
    public static let shared = Webservice()
    
    lazy private var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration,
                          delegate: nil,
                          delegateQueue: nil)
    }()
    
    deinit {
        session.invalidateAndCancel()
    }
    
    public func load<M>(resource: Resource<M>, token: CancelToken? = nil, completionHandler: @escaping (Result<M, Error>) -> Void) {
        let request = URLRequest(url: resource.url)
        let parse = resource.parse
        
        return load(request: request, parsingHandler: parse, token: token, completionHandler: completionHandler)
    }
    
    public func load<M>(request: URLRequest, parsingHandler: @escaping (Data) throws -> M, token: CancelToken? = nil, completionHandler: @escaping (Result<M, Webservice.Error>) -> Void) {
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                if let error = error as? Webservice.Error {
                    completionHandler(.failure(error))
                } else {
                    completionHandler(.failure(.other(error)))
                }
                
                return
            }
            
            guard let data = data else {
                assertionFailure("data should never be nil without describing error object")
                completionHandler(.failure(.data))
                return
            }
            
            do {
                let result = try parsingHandler(data)
                completionHandler(.success(result))
            } catch {
                completionHandler(.failure(.parsed(error)))
            }
        }
        
        token?.handler = {
            task.cancel()
        }
        
        task.resume()
    }
}

public extension Webservice {
    enum Error: Swift.Error {
        case parsed(Swift.Error)
        case data
        case other(Swift.Error)
    }
}
