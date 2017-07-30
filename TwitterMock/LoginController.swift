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
    
    let nameTextView: UITextField = {
        let tv = UITextField()
        let placeholderString = NSLocalizedString("Name", comment: "")
        tv.placeholder = placeholderString
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let emailTextView: UITextField = {
        let tv = UITextField()
        
        let placeholderString = NSLocalizedString("Email Address", comment: "")
        tv.placeholder = placeholderString
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.keyboardType = .emailAddress
        return tv
    }()
    
    let passwordTextView: UITextField = {
        let tv = UITextField()
        let placeholderString = NSLocalizedString("Password", comment: "")
        tv.placeholder = placeholderString
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
    
    lazy var loginRigisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.rgb(red: 80, green: 101, blue: 161)
        let title = NSLocalizedString("Register", comment: "")
        button.setTitle(title, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(loginRegisterHandler), for: .touchUpInside)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        return button
    }()

    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "avatar")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectorImageHandler)))
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    lazy var loginRegisterController: UISegmentedControl = {
        
        let login = NSLocalizedString("Login", comment: "")
        let register = NSLocalizedString("Register", comment: "")
        let item = [login, register]
        let sc = UISegmentedControl(items: item)
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleHideKeyBoard)))
        setupview()
        observeKeyboardNotifications()
    }
    func handleHideKeyBoard() {
        view.endEditing(true)
    }
    func setupview() {
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
    func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: .UIKeyboardWillHide, object: nil)
        
    }
    
    func keyboardShow() {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: {
                        
                        self.view.frame = CGRect(x: 0, y: -100, width: self.view.frame.width, height: self.view.frame.height)
        },
                       completion: nil)
    }
    
    func keyboardHide() {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: {
                        
                        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        },
                       completion: nil)
    

    }

    
    var inputContainerHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    func handleLoginRegisterChange() {
        let title = loginRegisterController.titleForSegment(at: loginRegisterController.selectedSegmentIndex)
        let localizeTitle = NSLocalizedString(title!, comment: "")
        loginRigisterButton.setTitle(localizeTitle, for: .normal)
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

        loginRegisterController.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterController.bottomAnchor.constraint(equalTo: inputsContrainerView.topAnchor, constant: -12).isActive = true
        
        loginRegisterController.widthAnchor.constraint(equalTo: inputsContrainerView.widthAnchor).isActive = true
        
        loginRegisterController.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
    }

    func setupProfileImageView() {
        
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: loginRegisterController.topAnchor, constant: -10).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
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
