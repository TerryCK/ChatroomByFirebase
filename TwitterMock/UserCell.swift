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
    
    
    let timeLabel: UILabel = {
        let tl = UILabel()
        tl.font = .systemFont(ofSize: 13)
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.textColor = .lightGray
        return tl
    }()
    
    var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "nedstark")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    func setupNameAndProfileImeag() {
        
        guard let id = message?.chatPartnerId else {
            return
        }
        
        let ref = Database.database().reference().child("users").child(id)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in

            guard let dictionary = snapshot.value as? [String: AnyObject],
                let name = dictionary["name"] as? String,
                let profileImageUrl = dictionary["profileImage"] as? String else {
                    return
            }
            
            self.textLabel?.text = name
            self.profileImageView.loadImageUsingCache(with: profileImageUrl)
            
        }, withCancel: nil)
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true

        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        
    }
    
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = cgRectMake(64, textLabel!.frame.origin.y, textLabel!.frame.width, textLabel!.frame.height)
       
        detailTextLabel?.frame = cgRectMake(64, detailTextLabel!.frame.origin.y, detailTextLabel!.frame.width, detailTextLabel!.frame.height)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

