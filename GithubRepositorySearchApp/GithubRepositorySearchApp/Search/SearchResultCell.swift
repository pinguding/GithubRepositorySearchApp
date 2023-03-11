//
//  SearchResultCell.swift
//  GithubRepositorySearchApp
//
//  Created by 박종우 on 2023/03/11.
//

import UIKit
import Kingfisher

final class SearchResultCell: BaseCollectionViewCell<SearchResultModel> {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var repositoryOwnerLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var stargazeCountLabel: UILabel!
    
    @IBOutlet weak var languageColor: UIImageView!
    
    @IBOutlet weak var languageLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        avatarImageView.image = nil
        repositoryOwnerLabel.text = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
        stargazeCountLabel.text = nil
        languageLabel.text = nil
    }
    
    override func configureCell(item: SearchResultModel) {
        if let url = URL(string: item.avatarImageURLString) {
            avatarImageView.kf.setImage(with: .network(url))
        }
        repositoryOwnerLabel.text = item.repositoryOwner
        titleLabel.text = item.title
        descriptionLabel.text = item.description
        if item.language.isEmpty {
            languageColor.isHidden = true
            languageLabel.isHidden = true
        } else {
            languageColor.isHidden = false
            languageLabel.isHidden = false
            languageLabel.text = item.language
        }
    }
}
