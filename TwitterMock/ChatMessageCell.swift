//
//  ChatMessageCell.swift
//  TwitterMock
//
//  Created by 陳 冠禎 on 2017/7/21.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
 
    let textView: UITextField = {
        let tv = UITextField()
        tv.backgroundColor = .brown
        tv.text = "samp"
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = .systemFont(ofSize: 16)
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    func setupView() {
        addSubview(textView)
        textView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        textView.widthAnchor.constraint(equalToConstant: self.frame.width / 2).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
