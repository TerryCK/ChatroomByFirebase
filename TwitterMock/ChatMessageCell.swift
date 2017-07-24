//
//  ChatMessageCell.swift
//  TwitterMock
//
//  Created by 陳 冠禎 on 2017/7/21.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {

    var chatLogController: ChatLogController?
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = .systemFont(ofSize: 16)
        tv.textColor = .white
        tv.isEditable = false
        return tv
    }()
    
    let bubbleView: UIView = {
        let bv = UIView()
        bv.backgroundColor = .bubbleBlue
        bv.translatesAutoresizingMaskIntoConstraints = false
        bv.layer.cornerRadius = 10
        bv.layer.masksToBounds = true
        
    return bv
    }()
    
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .brown
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    lazy var messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .brown
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageZooming)))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleRightAnchor: NSLayoutConstraint?
    var bubbleLeftAnchor: NSLayoutConstraint?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)

       
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        addSubview(messageImageView)
        
        
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        messageImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        bubbleRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleRightAnchor?.isActive = true
        
        
        bubbleLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)

        
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true

    }
    func handleImageZooming(tapGesture: UITapGestureRecognizer) {
        if let imeageView = tapGesture.view as? UIImageView {
            chatLogController?.performZoomInForStartingImageView(startingImageView: imeageView)
        }
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
