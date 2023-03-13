//
//  BaseViewController.swift
//  GithubRepositorySearchApp
//
//  Created by 박종우 on 2023/03/11.
//

import UIKit
import Combine

open class BaseViewController<ViewModel: BaseViewModel>: UIViewController {
    ///ViewModel 에서 ViewController 로 Update 할때 사용할 Model 에 대한 typealias 정의
    public typealias Model = ViewModel.Model
    
    ///class func build 때 Storyboard 로 부터 ViewController 를 불러올시 사용할 Storyboard Name, override 하지 않는다면 default 값은 Class 이름과 동일
    open class var nameOfStoryboard: String {
        String(describing: Self.self)
    }
    
    ///ViewModel 에 대한 선언. BaseViewController 의 Subclass 까지만 접근 가능하도록 internal 로 선언
    internal var viewModel: ViewModel?
    
    public var cancellable: Set<AnyCancellable> = []
    
    ///ViewController 와 ViewModel 을 조합해서 새로운 ViewController 를 생성할 때 사용하는 class function
    class func build(viewModel: ViewModel) -> UIViewController {
        let viewController = UIStoryboard(name: Self.nameOfStoryboard, bundle: .main).instantiateViewController(identifier: Self.nameOfStoryboard) { coder in
            let viewController = Self.init(coder: coder)
            viewController?.viewModel = viewModel
            return viewController
        }
        return viewController
    }
    
    ///viewDidLoad 에서 viewModel 의 Data 들과 sink 해주는 로직이 들어감
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel?.viewLifeCycle(.viewDidLoad)
        sinkViewModel()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        viewModel?.viewLifeCycle(.viewWillAppear)
    }
    
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel?.viewLifeCycle(.viewDidAppear)
    }
    
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel?.viewLifeCycle(.viewWillDisappear)
    }
    
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewModel?.viewLifeCycle(.viewDidDisappear)
    }
    
    open func modelUpdateHandler(updatedItems: [Model]) {
        
    }
}

extension BaseViewController {
    ///alertPublisher 와 modelPublisher 는 공통으로 사용되는 로직이기 때문에 override 하지 않아도 되어 private 으로 선언.
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



