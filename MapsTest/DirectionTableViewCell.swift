//
//  DirectionTableViewCell.swift
//  MapsTest
//
//  Created by 이치훈 on 2023/04/13.
//

import Foundation
import UIKit

class DirectionTableViewCell: UITableViewCell {
    
    var directionLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension DirectionTableViewCell: ConfigureSubviewsCase {
    
    func configureSubviews() {
        createSubviews()
        addSubviews()
        setupLayouts()
    }
    
    func createSubviews() {
        directionLabel = UILabel()
    }
    
    func addSubviews() {
        self.addSubview(directionLabel)
    }
    
    func setupLayouts() {
        setupSubviewsLayouts()
        setupSubviewsConstraints()
    }
    
}

extension DirectionTableViewCell: SetupSubviewsLayouts {
    
    func setupSubviewsLayouts() {
        directionLabel.text = "empty"
        directionLabel.tintColor = .black
    }
    
}

extension DirectionTableViewCell: SetupSubviewsConstraints {
    
    func setupSubviewsConstraints() {
        directionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            directionLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            directionLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
}
