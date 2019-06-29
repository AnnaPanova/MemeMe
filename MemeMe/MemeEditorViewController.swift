//
//  ViewController.swift
//  MemeMe
//
//  Created by Анна on 19/06/2019.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController {
    
    @IBOutlet weak var pickerImage: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topChooseTheFontButton: UIBarButtonItem!
    @IBOutlet weak var bottomChooseTheFontButton: UIBarButtonItem!
    
    let custumDelegate = CustomTextFieldDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        shareButton.isEnabled = false
        chooseTheFontIsEnabled()
        
        topTextField.delegate = custumDelegate
        bottomTextField.delegate = custumDelegate
        
        configureTextFields(topTextField, with: "TOP")
        configureTextFields(bottomTextField, with: "BOTTOM")
        
        view.addSubview(bottomView)
        view.addSubview(topView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        chekingTextFields()
        chooseTheFontIsEnabled()
        subscribeToKeyBoardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: Pick an Image
    @IBAction func pickAnImage(_ sender: UIBarButtonItem) {
        let source = UIImagePickerController()
        if sender.tag == 0 {
            source.sourceType = .photoLibrary
        } else {
            source.sourceType = .camera
        }
        pickAnImageFromSource(from: source.sourceType)
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
        chooseTheFontIsEnabled()
        if bottomTextField.isEditing {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
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
        self.topChooseTheFontButton.isEnabled = false
        self.bottomChooseTheFontButton.isEnabled = false
    }
    
    //MARK: Generate Memed Image
    func generateMemedImage() -> UIImage {
        hideOrShowToolBars(shouldHide: true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        hideOrShowToolBars(shouldHide: false)
        return memedImage
    }
    
    func hideOrShowToolBars(shouldHide: Bool) {
        topToolbar.isHidden = shouldHide
        bottomToolBar.isHidden = shouldHide
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
        custumDelegate.topEditedText = nil
        custumDelegate.bottomEditedText = nil
        configureTextFields(topTextField, with: "TOP")
        configureTextFields(bottomTextField, with: "BOTTOM")
        pickerImage.image = nil
        shareButton.isEnabled = false
        chooseTheFontIsEnabled()
    }
    
    // MARK: Choose the Font Action
    @IBAction func chooseFont(_ sender: Any) {
        let fontDict: [String: UIFont] = [
            "Helvetica Neue": UIFont(name: "HelveticaNeue-CondensedBlack", size: 40.0)!,
            "Marker Felt" : UIFont(name: "Marker Felt", size: 40.0)!,
            "Party Let" : UIFont(name: "Party Let", size: 40.0)!,
            "Zapfino": UIFont(name: "Zapfino", size: 20.0)!
        ]
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let helveticaFontAction = UIAlertAction(title: "Helvetica Neue", style: .default) { action in
            self.setFont(font: fontDict["Helvetica Neue"]!)
        }
        let markerFeltFontAction = UIAlertAction(title: "Marker Felt", style: .default) { action in
            self.setFont(font: fontDict["Marker Felt"]!)
        }
        let partyLetFontAction = UIAlertAction(title: "Party Let", style: .default) { action in
            self.setFont(font: fontDict["Party Let"]!)
        }
        let zapfinoFontAction = UIAlertAction(title: "Zapfino", style: .default) { action in
            self.setFont(font: fontDict["Zapfino"]!)
        }
        
        alertController.addAction(helveticaFontAction)
        alertController.addAction(markerFeltFontAction)
        alertController.addAction(partyLetFontAction)
        alertController.addAction(zapfinoFontAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setFont(font: UIFont) {
        if topTextField.isEditing == true {
            self.topTextField.font = font
            self.topTextField.resignFirstResponder()
        } else if bottomTextField.isEditing == true {
            self.bottomTextField.font = font
            self.bottomTextField.resignFirstResponder()
        }
    }
    
    // MARK: Configure textFields
    func configureTextFields(_ textField: UITextField, with defaultText: String) {
        // set center alignment for textFields
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let textFieldAttributes: [NSAttributedString.Key: Any] = [
            .strokeColor : UIColor.black,
            .foregroundColor : UIColor.white,
            .font : UIFontMetrics.default.scaledFont(for: UIFont(name: "Impact", size: 40.0)!),
            .strokeWidth : -3.0,
            .paragraphStyle: paragraph
        ]
        textField.defaultTextAttributes = textFieldAttributes
        textField.text = defaultText
    }
    
    // MARK: Pick an image from source
    func pickAnImageFromSource(from source: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    // MARK: Choose the font isHidden
    func chooseTheFontIsEnabled() {
        topChooseTheFontButton.isEnabled = false
        bottomChooseTheFontButton.isEnabled = false
        if topTextField.isEditing {
            topChooseTheFontButton.isEnabled = true
        } else if bottomTextField.isEditing {
            bottomChooseTheFontButton.isEnabled = true
        }
    }
}

extension MemeEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.pickerImage.image = image
        }
        dismiss(animated: true, completion: nil)
        shareButton.isEnabled = true
    }
}




