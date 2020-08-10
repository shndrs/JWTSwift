//
//  Presenter.swift
//  JWTSwift
//
//  Created by Sahand Raeisi on 8/10/20.
//  Copyright © 2020 Sahand Raeisi. All rights reserved.
//

import Alamofire

protocol View: AnyObject {
    func print(result: Any)
}

final class Presenter: NSObject {
    
    private weak var view: View?
    
    init(view: View) {
        self.view = view
    }
    
}

// MARK: - Methods

extension Presenter {
    
    func callAPI() {
        let requestUrl = Urls.base.rawValue + Urls.register.rawValue
        let sessionManager = Alamofire.SessionManager.default
        sessionManager.adapter = SRRequestAdapter.shared
        
        sessionManager.request(requestUrl).validate().responseJSON { (response: DataResponse<Any>) in
            switch(response.result) {
            case .success(let value):
                self.view?.print(result: value)
            case .failure(let error):
                self.view?.print(result: error)
            }
        }
    }
}
