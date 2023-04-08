//
//  CustomCalloutView.swift
//  MapsTest
//
//  Created by 이치훈 on 2023/04/09.
//

import Foundation
import UIKit

class CustomCalloutView: UIView {
    
    var annotation: Annotation!
    
    init(annotation: Annotation, frame: CGRect) {
        super.init(frame: frame)
        self.annotation = annotation
        self.frame = frame
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func add(to view: UIView) {
        view.addSubview(self)
        
        self.bottomAnchor.constraint(equalTo: view.topAnchor, constant: -5).isActive = true
        self.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.widthAnchor.constraint(equalToConstant: 150).isActive = true
        self.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    private func configure() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 10.0
        self.layer.masksToBounds = true
        self.backgroundColor = .blue
        
        let titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.textColor = .white
        titleLabel.text = annotation.title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(titleLabel)
        
        titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
}
