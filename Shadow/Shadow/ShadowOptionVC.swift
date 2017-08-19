//
//  ShadowOptionVC.swift
//  Shadow
//
//  Created by Sahil Arora on 5/31/17.
//  Copyright © 2017 Atinderjit Kaur. All rights reserved.
//

import UIKit

class ShadowOptionVC: UIViewController {

    @IBOutlet var btn_Next: UIButton!
    @IBOutlet var imageView_No: UIImageView!
    @IBOutlet var imageView_Yes: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

     //   self.navigationItem.hidesBackButton = true //Hide default back button
        let myBackButton:UIButton = UIButton()
        myBackButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        myBackButton.setImage(UIImage(named:"backpurple"), for: UIControlState())
        myBackButton.addTarget(self, action: #selector(self.PopToRootViewController), for: UIControlEvents.touchUpInside)
        let leftBackBarButton:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem = leftBackBarButton

        
        self.SetButtonCustomAttributesPurple(btn_Next)
        allowShadow = true
        
        
        imageView_Yes.image = UIImage(named:"purple")
        imageView_No.image = UIImage(named:"blank")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//MARK:- Button Actions
    
    @IBAction func Action_SelectShadowOptions(_ sender: UIButton) {
        
        if sender.tag == 0
        {
           imageView_Yes.image = UIImage(named:"purple")
            imageView_No.image = UIImage(named:"blank")
            allowShadow = true


        }
        else {
            imageView_Yes.image = UIImage(named:"blank")
            imageView_No.image = UIImage(named:"purple")
            allowShadow = false
        }
        
    }
    
    @IBAction func Action_Next(_ sender: UIButton) {
        username = firstName + " " + lastName
        
        if self.checkInternetConnection()
        {
            let dict = NSMutableDictionary()
            dict.setValue(str_email, forKey: Global.macros.kEmail)
            dict.setValue(registeringAs, forKey: "role")
            dict.setValue(password, forKey: Global.macros.kPassword)
            dict.setValue(false, forKey: "phoneOtp")
            dict.setValue(username, forKey: Global.macros.kUserName)
            dict.setValue(firstName, forKey: Global.macros.kFirstName)
            dict.setValue(lastName, forKey: Global.macros.kLastName)
            dict.setValue(countryCode, forKey: "countryCode")
            dict.setValue(schoolName, forKey: "schoolName")
            dict.setValue(Location, forKey: "location")
            dict.setValue(companyName, forKey: "companyName")
            dict.setValue(allowShadow, forKey: "OtherUserShadowYou")
            dict.setValue(true, forKey: "emailOtp")
            dict.setValue("1.1", forKey: Global.macros.kAppVersion)
            dict.setValue("1.1.1", forKey: Global.macros.kAppBuildNumber)
            dict.setValue(latitude, forKey: Global.macros.klatitude)
            dict.setValue(longitude, forKey: Global.macros.klongitude)
            
            print(dict)
            if self.checkInternetConnection(){
                
                    DispatchQueue.main.async{
                        self.pleaseWait()
                    }
                    
                    AuthenticationAPI.sharedInstance.Register(dict: dict, completion: {(response) in
                        print(response)
                        switch response {
                        case 200:
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "EmailToOTP", sender: self)
                            }
                            
                        case 226:
                            DispatchQueue.main.async {
                                self.showAlert(Message: "Email already exist.", vc: self)
                            }
                        default:
                            break
                        }
                        self.clearAllNotice()
                        
                    }, errorBlock: {(err) in
                        
                        DispatchQueue.main.async {
                            self.clearAllNotice()
                            self.showAlert(Message: Global.macros.kError, vc: self)
                        }
                    })
                
            }
            else{
                self.showAlert(Message: Global.macros.kInternetConnection, vc: self)
            }
            
         //  self.CreateAlert()
        }
        else
        {
            self.showAlert(Message: Global.macros.kInternetConnection, vc: self)

        }
    }
    

}
