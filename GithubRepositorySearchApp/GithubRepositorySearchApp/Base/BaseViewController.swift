//
//  BaseViewController.swift
//  GithubRepositorySearchApp
//
//  Created by 박종우 on 2023/03/11.
//

import UIKit
import Combine

open class BaseViewController<ViewModel: BaseViewModel>: UIViewController {
    
    public typealias Model = ViewModel.Model
    
    open class var nameOfStoryboard: String {
        String(describing: Self.self)
    }
    
    internal var viewModel: ViewModel?
    
    public var cancellable: Set<AnyCancellable> = []
    
    class func build(viewModel: ViewModel) -> UIViewController {
        let viewController = UIStoryboard(name: Self.nameOfStoryboard, bundle: .main).instantiateViewController(identifier: Self.nameOfStoryboard) { coder in
            let viewController = Self.init(coder: coder)
            viewController?.viewModel = viewModel
            return viewController
        }
        return viewController
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel?.viewLifeCycleUpdate(.viewDidLoad)
        sinkViewModel()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        viewModel?.viewLifeCycleUpdate(.viewWillAppear)
    }
    
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel?.viewLifeCycleUpdate(.viewDidAppear)
    }
    
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel?.viewLifeCycleUpdate(.viewWillDisappear)
    }
    
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewModel?.viewLifeCycleUpdate(.viewDidDisappear)
    }
    
    open func modelUpdateHandler(updatedItems: [Model]) {
        
    }
}

extension BaseViewController {
    
    private func sinkViewModel() {
        viewModel?.alertPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] alertModel in
                let alertController = UIAlertController(title: alertModel.title, message: alertModel.message, preferredStyle: .alert)
                alertModel.buttons.forEach { buttonModel in
                    let alertAction = UIAlertAction(title: buttonModel.buttonTitle, style: buttonModel.style, handler: buttonModel.buttonAction)
                    alertController.addAction(alertAction)
                }
                self?.present(alertController, animated: true)
            })
            .store(in: &cancellable)
        
        viewModel?.modelPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] updatedItems in
                self?.modelUpdateHandler(updatedItems: updatedItems)
            })
            .store(in: &cancellable)
    }
}



