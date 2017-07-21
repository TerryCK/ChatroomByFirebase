//
//  UserCell.swift
//  TwitterMock
//
//  Created by 陳 冠禎 on 2017/7/20.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell, CGMakeable {
    
    var message: Message? {
        didSet {
            
            setupNameAndProfileImeag()
            detailTextLabel?.text = message?.text
            
            if let seconds = message?.timestamp?.doubleValue {
                let timestampDate = Date(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                
                timeLabel.text = dateFormatter.string(from: timestampDate)
            }
            
            
            
         }
    }
    
    func setupNameAndProfileImeag() {
       
        
        
        if let id = message?.chatPartnerId() {
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.textLabel?.text = dictionary["name"] as? String
                    if let profileImageUrl = dictionary["profileImage"] as? String {
                        self.profileImageView.loadImageUsingCache(with: profileImageUrl)
                    }
                }
                
            }, withCancel: nil)
        }
        
    }
    
    var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "nedstark")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        addSubview(timeLabel)
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        
    }
    
    let timeLabel: UILabel = {
        let tl = UILabel()
        tl.font = .systemFont(ofSize: 13)
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.textColor = .lightGray
        return tl
    }()
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = cgRectMake(64, textLabel!.frame.origin.y, textLabel!.frame.width, textLabel!.frame.height)
        detailTextLabel?.frame = cgRectMake(64, detailTextLabel!.frame.origin.y, detailTextLabel!.frame.width, detailTextLabel!.frame.height)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

