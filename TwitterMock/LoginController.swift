//
//  LoginController.swift
//  TwitterMock
//
//  Created by 陳 冠禎 on 2017/7/17.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    
    var messageController: MessageController?
    
    let inputsContrainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var loginRigisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.rgb(red: 80, green: 101, blue: 161)
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(loginRegisterHandler), for: .touchUpInside)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        return button
    }()
    
    let nameTextView: UITextField = {
        let tv = UITextField()
        tv.placeholder = "Name"
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let emailTextView: UITextField = {
        let tv = UITextField()
        tv.placeholder = "Email Address"
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.keyboardType = .emailAddress
        return tv
    }()
    
    let passwordTextView: UITextField = {
        let tv = UITextField()
        tv.placeholder = "Password"
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isSecureTextEntry = true
        return tv
    }()
    
    
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 220, green: 220, blue: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 220, green: 220, blue: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "gameofthrones_splash")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectorImageHandler)))
        imageView.layer.cornerRadius = 75
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    lazy var loginRegisterController: UISegmentedControl = {
        let item = ["Login", "Register"]
        let sc = UISegmentedControl(items: item)
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blueLogin
        view.addSubview(inputsContrainerView)
        view.addSubview(loginRigisterButton)
        view.addSubview(profileImageView)
        view.addSubview(loginRegisterController)
        
        setupInputsContrainerView()
        setupLoginRegisterButton()
        setupLoginRegisterController()
        setupProfileImageView()
        
    }
    
    
    
    func loginRegisterHandler() {
        
        if loginRegisterController.selectedSegmentIndex == 0 {
            loginHandler()
        } else {
            registerHandle()
        }
        
        
    }
    func loginHandler() {
        guard let email = emailTextView.text, let password = passwordTextView.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print("login failure:", error)
                return
            }
            print("Auth successfully")
            self.messageController?.fetchUserAndSetNvigationItemTitle()
            self.dismiss(animated: true, completion: nil)
        }
        
        
    }
    
    
    var inputContainerHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    func handleLoginRegisterChange() {
        let title = loginRegisterController.titleForSegment(at: loginRegisterController.selectedSegmentIndex)
        
        loginRigisterButton.setTitle(title, for: .normal)
        let isSegmentIndexAtLogin = loginRegisterController.selectedSegmentIndex == 0 ? true : false
        
        inputContainerHeightAnchor?.constant =  isSegmentIndexAtLogin ? 100 : 150
        let nameTextFieldMultiplier: CGFloat = isSegmentIndexAtLogin  ? 0 : 1/3
        let textFieldMultiplier: CGFloat = isSegmentIndexAtLogin ? 1/2 : 1/3
        
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextView.heightAnchor.constraint(equalTo: inputsContrainerView.heightAnchor, multiplier: nameTextFieldMultiplier)
        nameTextFieldHeightAnchor?.isActive = true
        nameTextView.isHidden = isSegmentIndexAtLogin
        
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextView.heightAnchor.constraint(equalTo: inputsContrainerView.heightAnchor, multiplier: textFieldMultiplier)
        emailTextFieldHeightAnchor?.isActive = true
        
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextView.heightAnchor.constraint(equalTo: inputsContrainerView.heightAnchor, multiplier: textFieldMultiplier)
        passwordTextFieldHeightAnchor?.isActive = true
        
    }
    
    
    
    func setupLoginRegisterController() {
        // x, y, height, width
        
        
        loginRegisterController.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterController.bottomAnchor.constraint(equalTo: inputsContrainerView.topAnchor, constant: -12).isActive = true
        
        loginRegisterController.widthAnchor.constraint(equalTo: inputsContrainerView.widthAnchor).isActive = true
        
        loginRegisterController.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
    }
    
    
    
    
    func setupProfileImageView() {
        
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: loginRegisterController.topAnchor, constant: -12).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
    }
    
    
    func setupLoginRegisterButton() {
        
        loginRigisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRigisterButton.topAnchor.constraint(equalTo: inputsContrainerView.bottomAnchor, constant: 12).isActive = true
        loginRigisterButton.widthAnchor.constraint(equalTo: inputsContrainerView.widthAnchor).isActive = true
        loginRigisterButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    
    
    
    
    func setupInputsContrainerView() {
        
        
        inputsContrainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContrainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContrainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputContainerHeightAnchor = inputsContrainerView.heightAnchor.constraint(equalToConstant: 150)
        inputContainerHeightAnchor?.isActive = true
        
        
        inputsContrainerView.addSubview(nameTextView)
        inputsContrainerView.addSubview(nameSeparatorView)
        inputsContrainerView.addSubview(emailTextView)
        inputsContrainerView.addSubview(emailSeparatorView)
        inputsContrainerView.addSubview(passwordTextView)
        
        
        nameTextView.leftAnchor.constraint(equalTo: inputsContrainerView.leftAnchor, constant: 12).isActive = true
        nameTextView.topAnchor.constraint(equalTo: inputsContrainerView.topAnchor).isActive = true
        
        nameTextView.widthAnchor.constraint(equalTo: inputsContrainerView.widthAnchor).isActive = true
        nameTextFieldHeightAnchor = nameTextView.heightAnchor.constraint(equalTo: inputsContrainerView.heightAnchor, multiplier: 1/3)
        
        nameTextFieldHeightAnchor?.isActive = true
        
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContrainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextView.bottomAnchor).isActive = true
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContrainerView.leftAnchor).isActive = true
        
        emailTextView.leftAnchor.constraint(equalTo: inputsContrainerView.leftAnchor, constant: 12).isActive = true
        emailTextView.topAnchor.constraint(equalTo: nameSeparatorView.bottomAnchor).isActive = true
        
        emailTextView.widthAnchor.constraint(equalTo: inputsContrainerView.widthAnchor).isActive = true
        emailTextFieldHeightAnchor = emailTextView.heightAnchor.constraint(equalTo: inputsContrainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        emailSeparatorView.widthAnchor.constraint(equalTo: emailTextView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextView.bottomAnchor).isActive = true
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContrainerView.leftAnchor).isActive = true
        
        passwordTextView.leftAnchor.constraint(equalTo: inputsContrainerView.leftAnchor, constant: 12).isActive = true
        passwordTextView.topAnchor.constraint(equalTo: emailSeparatorView.bottomAnchor).isActive = true
        
        passwordTextView.widthAnchor.constraint(equalTo: inputsContrainerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextView.heightAnchor.constraint(equalTo: inputsContrainerView.heightAnchor, multiplier: 1/3)
        
        passwordTextFieldHeightAnchor?.isActive = true
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
