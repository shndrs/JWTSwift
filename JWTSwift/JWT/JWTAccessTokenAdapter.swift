//
//  JWTAccessTokenAdapter.swift
//  JWTSwift
//
//  Created by Sahand Raeisi on 8/10/20.
//  Copyright © 2020 Sahand Raeisi. All rights reserved.
//

import Alamofire

final class JWTAccessTokenAdapter: RequestAdapter {
    
    typealias JWT = String
    private let accessToken: JWT

    init(accessToken: JWT) {
        self.accessToken = accessToken
    }

    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        
        var urlRequest = urlRequest
        if let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix("https://api.authenticated.com") {
            urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        }
        return urlRequest
    }
}
