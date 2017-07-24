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
    
    var messages = [Message]() {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    
    
    private func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        
    }
    
    
    func handleKeyboardWillHide(notification: NSNotification) {
        
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        containViewBottonAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
        
        
    }
    
    var containViewBottonAnchor: NSLayoutConstraint?
    
    func handleKeyboardWillShow(notification: NSNotification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        containViewBottonAnchor?.constant = -(keyboardFrame?.height)!
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    
    
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
                if message.chatPartnerId == self.user?.id {
                    self.messages.append(message)
                }
                
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
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 8, 0)
//        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 50, 0)
        collectionView?.keyboardDismissMode = .interactive
        //
        //        observeKeyboardNotifications()
        //        setupView()
    }
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = .white
        containerView.addSubview(self.inputTextField)
        containerView.addSubview(self.sendButton)
        containerView.addSubview(self.separatorView)
        
        self.inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: self.sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        self.inputTextField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        self.sendButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        self.sendButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        self.sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        self.sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        
        self.separatorView.bottomAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        self.separatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        self.separatorView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        self.separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
       return containerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
        
    }
    
    func setupView() {
        
        view.addSubview(containerView)
        
        
        
        
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        containViewBottonAnchor =  containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containViewBottonAnchor?.isActive = true
        
        
        
        
        
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        if let text = messages[indexPath.item].text {
            height = estimateFrameForText(text: text).height + 20
        }
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        
        setupCell(cell: cell, message: message)
        
        // modify
        if let profileImageUrl = user?.profileImage {
            cell.profileImageView.loadImageUsingCache(with: profileImageUrl)
        }
        
        
        if let text = message.text {
            let width = estimateFrameForText(text: text).width
            cell.bubbleWidthAnchor?.constant = width + 32
            cell.textView.text  = message.text
        }
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message){
        if message.fromId == Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = UIColor.bubbleBlue
            cell.textView.textColor = .white
            cell.bubbleLeftAnchor?.isActive = false
            cell.bubbleRightAnchor?.isActive = true
            cell.profileImageView.isHidden = true
            
        } else {
            cell.bubbleView.backgroundColor = .lightGray
            cell.textView.textColor = .black
            cell.bubbleRightAnchor?.isActive = false
            cell.bubbleLeftAnchor?.isActive = true
            cell.profileImageView.isHidden = false
            
        }
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
}


