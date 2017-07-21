//
//  ChatLogController.swift
//  TwitterMock
//
//  Created by 陳 冠禎 on 2017/7/20.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, CGMakeable {
    
    let cellId = "cellid"
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            
            observeMessage()
        }
    }
    
    var messages = [Message]()
    
    func observeMessage() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let userMessageRef = Database.database().reference().child("user-messages").child(uid)
        
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            let messageID = snapshot.key
            
            
            let messageRef = Database.database().reference().child("message").child(messageID)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                let message = Message()
                message.setValuesForKeys(dictionary)
                self.messages.append(message)
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    let containerView: UIView = {
        let cv = UIView()
        cv.backgroundColor = .white
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    lazy var inputTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        tf.delegate = self
        tf.placeholder = "Enter message..."
        return tf
        
    }()
    
    let separatorView: UIView = {
        let sv = UIView()
        sv.backgroundColor = UIColor.rgb(red: 220, green: 220, blue: 220)
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    let sendButton: UIButton = {
        
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Send", for: .normal)
        btn.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        return btn
    }()
    
    func sendMessage() {
        let ref = Database.database().reference().child("message")
        let childRef = ref.childByAutoId()
        let toId = user?.id ?? ""
        let fromId = Auth.auth().currentUser?.uid ?? ""
        let timestamp = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        let values = ["text": inputTextField.text!, "toId": toId, "fromId": fromId, "timestamp": timestamp] as [String : Any]
        
        
        childRef.updateChildValues(values) { (err, ref) in
            if let err = err {
                print(err)
                return
            }
            
            let userMessageRef = Database.database().reference().child("user-messages").child(fromId)
            
            let messageId = childRef.key
            userMessageRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
            
            
        }
        inputTextField.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        
        setupView()
    }
    
    func setupView() {
        
        view.addSubview(containerView)
        view.addSubview(separatorView)
        containerView.addSubview(inputTextField)
        
        
        containerView.addSubview(sendButton)
        
        separatorView.bottomAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        separatorView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        inputTextField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        sendButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: view.frame.width, height: 80)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        
        cell.backgroundColor = .brown
        
        
        return cell
    }
}


