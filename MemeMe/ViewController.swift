//
//  ViewController.swift
//  MemeMe
//
//  Created by Анна on 19/06/2019.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var pickerImage: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    let custumDelegate = CustomTextFieldDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        shareButton.isEnabled = false
        
        topTextField.delegate = custumDelegate
        bottomTextField.delegate = custumDelegate
        
        view.addSubview(bottomView)
        view.addSubview(topView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // set center alignment for textFields
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let textFieldAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor : UIColor.black,
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth : -3.0,
            NSAttributedString.Key.paragraphStyle: paragraph
        ]
        
        topTextField.defaultTextAttributes = textFieldAttributes
        bottomTextField.defaultTextAttributes = textFieldAttributes
        
        chekingTextFields()
        subscribeToKeyBoardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: Pick an Image from Album
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    
    // MARK: Pick an Image from Camera
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .camera
        present(pickerController, animated: true, completion: nil)
    }
    
    
    func subscribeToKeyBoardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Moving the entire view up to keep the bottomTextField on screen
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isEditing {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgSizeValue.height
    }
    
    // Moving the entire view down
    @objc func keyboardWillHide(_ notification: Notification) {
        self.view.frame.origin.y = 0.0
    }
    
    //MARK: Generate Memed Image
    func generateMemedImage() -> UIImage {
        topToolbar.isHidden = true
        bottomToolBar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        topToolbar.isHidden = false
        bottomToolBar.isHidden = false
        
        return memedImage
    }
    
    func chekingTextFields() {
        if custumDelegate.topEditedText != nil {
            topTextField.text = custumDelegate.topEditedText
        } else {
            topTextField.text = "TOP"
        }
        
        if custumDelegate.bottomEditedText != nil {
            bottomTextField.text = custumDelegate.bottomEditedText
        } else {
            bottomTextField.text = "BOTTOM"
        }
    }
    
    // MARK: Share Action
    @IBAction func shareAction(_ sender: Any) {
        if let image = pickerImage.image {
            let memedImage = self.generateMemedImage()
            let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
            activityController.completionWithItemsHandler = {
                (activity, success, items, error) in
                if(success && error == nil){
                    // save the Meme
                    let meme = Meme(topText: self.topTextField.text!, bottomText: self.bottomTextField.text!, originalImage: image, memedImage:memedImage)
                    self.dismiss(animated: true, completion: nil);
                }
                else if (error != nil){
                    print(error)
                }
            }
            present(activityController, animated: true, completion: nil)
        }
    }
    
    // MARK: Cancel Action
    @IBAction func cancelAction(_ sender: Any) {
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        pickerImage.image = nil
        shareButton.isEnabled = false
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.pickerImage.image = image
        }
        dismiss(animated: true, completion: nil)
        shareButton.isEnabled = true
    }
    
}

