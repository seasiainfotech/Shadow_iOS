//
//  EnterUserNameViewController.swift
//  Shadow
//
//  Created by Atinderjit Kaur on 31/05/17.
//  Copyright © 2017 Atinderjit Kaur. All rights reserved.
//

import UIKit

public var username:String = ""
public var schoolName:String = ""
public var companyName:String = ""
public var Location:String = ""
public var latitude:String = ""
public var longitude:String = ""
public var password:String = ""
public var firstName:String = ""
public var lastName:String = ""
public var countryCode:String = ""
public var allowShadow:Bool = true
public var str_email:String = ""


class EnterUserNameViewController: UIViewController {

    @IBOutlet weak var textfield_Username: UITextField!
    @IBOutlet var btn_Next:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SetButtonCustomAttributes(btn_Next)
        
        textfield_Username.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)

        
    }
    func textFieldDidChange(textField:UITextField)
    {
        print(textField.text!)
        if  textfield_Username.text != ""  &&  self.isValidEmail(textfield_Username.text!) {
            
            SetButtonCustomAttributesPurple(btn_Next)
        }
        else {
            
            SetButtonCustomAttributes(btn_Next)
        }

    }
   
   
    
    //To hide Keyboard from the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
       self.view.endEditing(true)
   
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        bool_Backntn = false
        add_padding(textfield: textfield_Username)
        let myBackButton:UIButton = UIButton()
        myBackButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        myBackButton.setImage(UIImage(named:"backpurple"), for: UIControlState())
        myBackButton.addTarget(self, action: #selector(self.PopToRootViewController), for: UIControlEvents.touchUpInside)
        let leftBackBarButton:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem = leftBackBarButton
        Validations() //To disable user interaction of next button
    }
    
    //API TO Check availability of Email
    
    fileprivate func CheckEmail()
    {
        let dict = NSMutableDictionary()
        dict.setValue(textfield_Username.text, forKey: "email")
        
        //Loader
        DispatchQueue.main.async {
          self.pleaseWait()
        }
      
        AuthenticationAPI.sharedInstance.CheckAvailabilityOfUsername(dict: dict, completion: {(response) in
            
            
            switch response {
                
            case 226:
                self.showAlert(Message: Global.macros.kEmailExist, vc: self)

            case 404:
                DispatchQueue.main.async
                    {
                str_email = self.textfield_Username.text!
                   self.performSegue(withIdentifier: "UsernameToPassword", sender: self)
                }
                
            default:
                break
            }
            DispatchQueue.main.async {
            self.clearAllNotice()
            }
            
        }, errorBlock: {(err) in
            
            self.clearAllNotice()
            self.showAlert(Message: Global.macros.kError, vc: self)

            
        })
        
    }
    
    
    //Validation
    
   fileprivate func Validations()
    {
        
        if (textfield_Username.text?.characters.count)! > 5
        {
            btn_Next.isUserInteractionEnabled = true
        }
        else
        {
            btn_Next.isUserInteractionEnabled = false
        }
        }
        
    
    
    
    //MARK:- Button Actions
    @IBAction func Action_Next(_ sender:UIButton)
    {
        let str = textfield_Username.text?.trimmingCharacters(in: .whitespacesAndNewlines)

        
        if str != ""
        {
        if self.checkInternetConnection()
        {
            
         if self.isValidEmail(str!) {
                //API to check availibility of username
                
                DispatchQueue.global(qos: .background).async
                {
                 self.CheckEmail()
                }
           // self.performSegue(withIdentifier: "UsernameToPassword", sender: self)
            
            }
            else
            {
                self.showAlert(Message: "Please enter valid email", vc: self)

            }
        }
        else
        {
            self.showAlert(Message: Global.macros.kInternetConnection, vc: self)

        }
        
    }
        
        else {
            self.showAlert(Message: "Please enter email.", vc: self)

            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}
extension EnterUserNameViewController:UITextFieldDelegate{
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
    //    textField.text?.capitalizeFirstLetter()
        
        
        if textField == textfield_Username {
            
           

            
            let string: NSString = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString
            
            if (string.length > 0) {
                
                if string.hasPrefix(" ") {
                    return false
                }
                else if string.hasSuffix(" ") {
                    return false
                }
               
                
                btn_Next.isUserInteractionEnabled = true
                return string.length < 50
            }
            else{
                btn_Next.isUserInteractionEnabled = false
                return string.length < 50

            }
        }
        
               
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       
        textField.resignFirstResponder()
            //Validations()
            return true
       
       
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
      
        if (textField.text?.characters.count)! >= 6 {
            
            SetButtonCustomAttributesPurple(btn_Next)
        }
        else {
            
            SetButtonCustomAttributes(btn_Next)
        }
       
       
    }
    
    
}
