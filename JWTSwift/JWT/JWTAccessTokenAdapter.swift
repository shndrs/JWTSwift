//
//  JWTAccessTokenAdapter.swift
//  JWTSwift
//
//  Created by Sahand Raeisi on 8/10/20.
//  Copyright © 2020 Sahand Raeisi. All rights reserved.
//

import Alamofire
import UIKit

final class SRRequestAdapter: RequestAdapter, RequestRetrier {
    
    private typealias RefreshCompletion = (_ succeeded: Bool, _ accessToken: String?) -> Void

    private let lock = NSLock()

    private var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    var accessToken:String? = nil
    var refreshToken:String? = nil
    static let shared = SRRequestAdapter()

    private init(){
        let sessionManager = Alamofire.SessionManager.default
        sessionManager.adapter = self
        sessionManager.retrier = self
    }

    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest

        if let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix("BASE_URL"), !urlString.hasSuffix("/renew") {
            if let token = accessToken {
                urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        return urlRequest
    }


    // MARK: - RequestRetrier

    func should(_ manager: SessionManager, retry request: Request,
                with error: Error, completion: @escaping RequestRetryCompletion) {
        
        lock.lock() ; defer { lock.unlock() }

        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            requestsToRetry.append(completion)

            if !isRefreshing {
                refreshTokens { [weak self] succeeded, accessToken in
                    guard let strongSelf = self else { return }

                    strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }

                    if let accessToken = accessToken {
                        strongSelf.accessToken = accessToken
                    }

                    strongSelf.requestsToRetry.forEach { $0(succeeded, 0.0) }
                    strongSelf.requestsToRetry.removeAll()
                }
            }
        } else {
            completion(false, 0.0)
        }
    }

    // MARK: - Private Refresh Tokens

    private func refreshTokens(completion: @escaping RefreshCompletion) {
        guard !isRefreshing else { return }

        isRefreshing = true

        let urlString = "\("BASE_URL")token/renew"

        Alamofire.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization":"Bearer \(refreshToken!)"]).responseJSON { [weak self] response in
            guard let strongSelf = self else { return }
            if
                let json = response.result.value as? [String: Any],
                let accessToken = json["accessToken"] as? String
            {
                completion(true, accessToken)
            } else {
                completion(false, nil)
            }
            strongSelf.isRefreshing = false
        }
    }
    
}

class Sahand {
    
    func std() {
        
        let request_url = "Constants.API_URL" + "/path/to/resource"
        let sessionManager = Alamofire.SessionManager.default
        sessionManager.adapter = SRRequestAdapter.shared
        
        sessionManager.request(request_url).validate().responseJSON { (response: DataResponse<Any>) in
            switch(response.result) {
            case .success(_):
                print(response.result.value!)
//                completion(response.result.value!)
            case .failure(_):
                print(response.result.error!)
//                completion(response.result.error!)
            }
        }
    }
    
}
