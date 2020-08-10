//
//  ViewController.swift
//  JWTSwift
//
//  Created by Sahand Raeisi on 8/10/20.
//  Copyright © 2020 Sahand Raeisi. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    private lazy var presenter: Presenter = {
        return Presenter(view: self)
    }()

}

// MARK: - Life Cycle

extension ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.callAPI()
    }
    
}

// MARK: - View Implementation

extension ViewController: View {
    
    func print(result: Any) {
        
    }
    
}
