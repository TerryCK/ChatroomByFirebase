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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        let image = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(newMessageHandler))
        
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        checkUserLoggedIn()
        
        
    }
    
    
    func observeUserMessage() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let fDataBaseRef = Database.database().reference()
        
        let ref = fDataBaseRef.child("user-messages").child(uid)
        
        ref.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messageReference = fDataBaseRef.child("message").child(messageId)
            messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
                
                self.setupMessages(with: snapshot.value)
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    private func setupMessages(with value: Any?) {
        
        guard let dictionary = value as? [String: AnyObject] else {
            return
        }
        
        let message = Message()
        message.setValuesForKeys(dictionary)
        
        guard let chatPartnerId = message.chatPartnerId else {
            return
        }
        guard Auth.auth().currentUser?.uid != chatPartnerId else {
            return
        }
        
        self.messageDictionary[chatPartnerId] = message
        self.messages = Array(self.messageDictionary.values)
        
        self.messages.sort { (message1, message2) -> Bool in
            
            return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
        }
        
        timer?.invalidate()
        print("cancel timer")
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
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            let user = User()
            user.setValuesForKeys(dictionary)
            
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
    
    func clearUpMessageList() {
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
    
    func setupNavBarTitle(user: User) {
        
        clearUpMessageList()
        observeUserMessage()
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.addSubview(containerView)
        
        
        
        if let profileImageUrl = user.profileImage  {
            profileImageView.loadImageUsingCache(with: profileImageUrl)
        }
        
        
        let label = UILabel()
        label.text = user.name
        label.translatesAutoresizingMaskIntoConstraints = false
        
        
        containerView.addSubview(profileImageView)
        containerView.addSubview(label)
        
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        label.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        
        label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        label.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        label.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        
        
        self.navigationItem.titleView = titleView
    }
    
    
    func showChatLogController(user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    var messages = [Message]()
    var timer: Timer?
    
    func handlerReloadTable() {
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
                
                let user = User()
                user.setValuesForKeys(dictionary)
                
                user.id = chatPartnerId
                self.showChatLogController(user: user)
            }
            
        }, withCancel: nil)
    }
}

