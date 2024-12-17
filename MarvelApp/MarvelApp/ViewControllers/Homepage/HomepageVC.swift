//
//  HomepageVC.swift
//  MarvelApp
//
//  Created by Caner Tüysüz on 4.12.2024.
//

import UIKit

final class HomepageVC: UIViewController {
    
    private let viewModel: HomepageViewModelProtocol
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(viewModel: HomepageViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.didLoad()
    }
}
