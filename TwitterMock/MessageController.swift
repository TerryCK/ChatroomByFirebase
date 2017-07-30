//
//  ViewController.swift
//  TwitterMock
//
//  Created by 陳 冠禎 on 2017/7/17.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit
import Firebase

class MessageController: UITableViewController {
    
    var cellId = "cellid"
    var users = [User]()
    var messages = [Message]()
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)

        tableView.allowsMultipleSelectionDuringEditing = true
        checkUserLoggedIn()
        setupNavigationItem()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let message = self.messages[indexPath.row]
        if let chatPartnerId = message.chatPartnerId {
            Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
                if error != nil {
                    print(error)
                    return
                }
                self.messageDictionary.removeValue(forKey: chatPartnerId)
                self.attempReloadTheTable()
                
            })
        }
        
    
    }
    
    func setupNavigationItem() {
        
        let title = NSLocalizedString("Logout", comment: "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: title,
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(handleLogout))
        let image = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(newMessageHandler))
    }
    
    func observeUserMessage() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        
        ref.observe(.childAdded, with: { (snapshot) in
            let userId = snapshot.key
            
            ref.child(userId).observe(.childAdded, with: { (snapshot) in
                let messageId = snapshot.key
                self.fetchMessageAndAttempReload(messageId: messageId)
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    
    
    ref.observe(.childRemoved, with: { (snapshot) in
        
        self.messageDictionary.removeValue(forKey: snapshot.key)
        self.attempReloadTheTable()
        
    }, withCancel: nil)
    
    
    }
    
    
    private func fetchMessageAndAttempReload(messageId: String){

        let messageReference = Database.database().reference().child("message").child(messageId)
        messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.setupMessages(with: snapshot.value)
            
        }, withCancel: nil)

    }
    private func setupMessages(with value: Any?) {
        
        guard let dictionary = value as? [String: AnyObject] else {
            return
        }
        
        let message = Message(dictionary: dictionary)
    
        
        guard let chatPartnerId = message.chatPartnerId,
            Auth.auth().currentUser?.uid != chatPartnerId else {
            return
        }
        
        
        self.messageDictionary[chatPartnerId] = message
        attempReloadTheTable()
        
        
        
    }
    
    private func attempReloadTheTable() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.handlerReloadTable), userInfo: nil, repeats: false)
    }

    func newMessageHandler() {
        let newMessageController = NewMessageController()
        newMessageController.messageController = self
        
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func checkUserLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            handleLogout()
            
        } else {
            fetchUserAndSetNvigationItemTitle()
            
        }
    }
    
    
    func fetchUserAndSetNvigationItemTitle() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { [unowned self](snapshot) in
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            let user = User(dictionary: dictionary)
            
            
            self.users.append(user)
            self.setupNavBarTitle(user: user)
            
            }, withCancel: nil)
    }
    
    func handleLogout() {
        
        do {
            try Auth.auth().signOut()
            
        } catch let logoutError {
            print(logoutError)
        }
        
        clearUpMessageList()
        
        let loginController = LoginController()
        loginController.messageController = self
        present(loginController, animated: true, completion: nil)
    }
    
    private func clearUpMessageList() {
        messages.removeAll()
        messageDictionary.removeAll()
        tableView.reloadData()
    }
    
   let titleView: UIView = {
        let tv = UIView()
        tv.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        tv.isUserInteractionEnabled = true
        return tv
    }()
    
    let profileImageView: UIImageView = {
        let piv = UIImageView()
        piv.translatesAutoresizingMaskIntoConstraints = false
        piv.contentMode = .scaleAspectFill
        piv.clipsToBounds = true
        piv.layer.cornerRadius = 20
        return piv
    }()
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
  private func setupNavBarTitle(user: User) {
        
        clearUpMessageList()
        observeUserMessage()
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.addSubview(containerView)
        
        
        
        if let profileImageUrl = user.profileImage  {
            profileImageView.loadImageUsingCache(with: profileImageUrl)
        }
        
        
    
        titleLabel.text = user.name
    
        
        
        containerView.addSubview(profileImageView)
        containerView.addSubview(titleLabel)
        
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        titleLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        
        titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        titleLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        titleLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        
        
        self.navigationItem.titleView = titleView
    }
    
    
    func showChatLogController(user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    
    func handlerReloadTable() {
        self.messages = Array(self.messageDictionary.values)
        self.messages.sort { (message1, message2) -> Bool in
            guard let m1 = message1.timestamp?.intValue, let m2 = message2.timestamp?.intValue else {
                return false
            }
            return  m1 > m2
        }
        
        print("reloaded the table")
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    var messageDictionary = [String: Message]()
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        cell.message = messages[indexPath.row]
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId else {
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let user = User(dictionary: dictionary)
                
                
                user.id = chatPartnerId
                self.showChatLogController(user: user)
            }
            
        }, withCancel: nil)
    }
}

