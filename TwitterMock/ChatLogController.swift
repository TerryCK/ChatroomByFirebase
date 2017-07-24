//
//  ChatLogController.swift
//  TwitterMock
//
//  Created by 陳 冠禎 on 2017/7/20.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, CGMakeable, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
            let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
            
        }
    }
    
    
    
    private func observeKeyboardNotifications() {
        //        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        //
        //        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: .UIKeyboardDidShow, object: nil)
    }
    func handleKeyboardDidShow() {
        
        if messages.count > 0 {
            let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
        
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
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id  else {
            return
        }
        
        let userMessageRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            let messageID = snapshot.key
            
            
            let messageRef = Database.database().reference().child("message").child(messageID)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                self.messages.append(Message(dictionary: dictionary))
                
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    
    
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
        
        observeKeyboardNotifications()
        
    }
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = .white
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "upload_image_icon")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(uploadImageView)
        
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        containerView.addSubview(self.inputTextField)
        containerView.addSubview(self.sendButton)
        
        containerView.addSubview(self.separatorView)
        
        self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
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
    
    
    func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            
            uploadToFirebaseStorageUsingImage(image: selectedImage)
            
            
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage) {
        let imageName = UUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.1) {
            ref.putData(uploadData, metadata: nil, completion: { (metaData, error) in
                if error != nil {
                    print(error!)
                }
                
                if let downloadurl = metaData?.downloadURL()?.absoluteString {
                    self.sendImageMessage(imageUrl: downloadurl, image: image)
                }
                
            })
        }
        
        
    }
    
    
    
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
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        if let text = message.text {
            height = estimateFrameForText(text: text).height + 20
            
        } else if let imageHeight = message.imageHeight?.floatValue, let imageWidth = message.imageWidth?.floatValue {
            
            height = CGFloat(imageHeight / imageWidth * 200)
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
            //            h1 = w1 , h2 = w2
            //            w2 = w1 * h2 /h1
            
            cell.bubbleWidthAnchor?.constant = width + 32
            cell.textView.text  = message.text
        } else if message.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
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
        
        if let imageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCache(with: imageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = .clear
            cell.textView.isHidden = true
            cell.chatLogController = self
            
        } else {
            cell.messageImageView.isHidden = true
            cell.textView.isHidden = false
        }
        
    }
    func sendMessage() {
        sendMessageWithProperties(properties: ["text": inputTextField.text ?? ""] as [String: AnyObject])
    }
    
    private func sendImageMessage(imageUrl: String, image: UIImage) {
        
        let values = ["imageUrl": imageUrl, "imageHeight": image.size.height, "imageWidth": image.size.width] as [String : AnyObject]
        sendMessageWithProperties(properties: values)
    }
    
    
    private func sendMessageWithProperties(properties: [String: AnyObject]) {
        let ref = Database.database().reference().child("message")
        let childRef = ref.childByAutoId()
        let toId = user?.id ?? ""
        let fromId = Auth.auth().currentUser?.uid ?? ""
        let timestamp = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        
        
        
        var values = [ "toId": toId, "fromId": fromId, "timestamp": timestamp] as [String : Any]
        
        properties.forEach {  values[$0] = $1 }
        
        childRef.updateChildValues(values) { (err, ref) in
            
            if let err = err {
                print(err)
                return
            }
            
            self.inputTextField.text = nil
            let userMessageRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            
            let messageId = childRef.key
            userMessageRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            
            recipientUserMessagesRef.updateChildValues([messageId: 1])
            
        }
    }
    
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    
    
    func performZoomInForStartingImageView(startingImageView: UIImageView) {
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
       
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = .brown
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.image = startingImageView.image

        
        if let keyWindow = UIApplication.shared.keyWindow {
          self.blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = .black
            blackBackgroundView?.alpha = 0
            
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.inputContainerView.alpha = 0
                self.blackBackgroundView?.alpha = 1
                
                if let startHeight = self.startingFrame?.height, let startWidth = self.startingFrame?.width {
                    
                    let height = startHeight / startWidth * keyWindow.frame.width
                    zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                    zoomingImageView.center = keyWindow.center
                }

            }, completion: nil)
        }
    }
    
    
    
    func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        if let zoomOutimageView = tapGesture.view {
            zoomOutimageView.layer.cornerRadius = startingImageView!.layer.cornerRadius
            zoomOutimageView.layer.masksToBounds = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutimageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
                
                
                
            }, completion: { (completion) in
                zoomOutimageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
        
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
}


