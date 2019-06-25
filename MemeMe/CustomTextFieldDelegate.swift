//
//  CustomTextFieldDelegate.swift
//  MemeMe
//
//  Created by Анна on 20/06/2019.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation
import UIKit
class CustomTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    var topEditedText: String?
    var bottomEditedText: String?
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP" {
            textField.text = ""
        } else if textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 0 {
            topEditedText = textField.text
        } else {
            bottomEditedText = textField.text
        }
        return true
    }
    
}
