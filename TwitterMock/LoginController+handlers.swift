//
//  LoginController+handlers.swift
//  TwitterMock
//
//  Created by 陳 冠禎 on 2017/7/19.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func selectorImageHandler() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
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
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func registerHandle() {
        
        guard let email = emailTextView.text,
            let password = passwordTextView.text,
            let name = nameTextView.text,
            let image = profileImageView.image else {
                return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user , error) in
            if error != nil {
                print(error as Any)
            }
            
            guard let uid = user?.uid else {
                return
            }

            let imageName = UUID().uuidString
            let storageRef = Storage.storage().reference().child("\(imageName).jpg")
            
            guard let uploadData = UIImageJPEGRepresentation(image, 0.1) else {
                return
            }
            
                storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                    if let err = error {
                        print(err)
                    }
                    guard let profileImageUrl = metadata?.downloadURL()?.absoluteString else {
                        return
                    }

                    let values = ["name": name, "email": email, "profileImage": profileImageUrl]
                    self.messageController?.navigationItem.title = name
                    self.registerUserIntoDatabase(uid: uid, values: values as [String : AnyObject])
                }
            
        }
        
    }
    
    
    private func registerUserIntoDatabase(uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference()
        
        let usersReference = ref.child("users").child(uid)
       
        usersReference.updateChildValues(values) { (err, ref) in
            
            guard err == nil else {
                print(err)
                return
            }
            
            
            self.dismiss(animated: true, completion: nil)
            print("Saved user sucessfully in to firebase db")
        }
    }
    
}
