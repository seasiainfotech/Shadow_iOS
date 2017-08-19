//
//  SideMenuBarViewController.swift
//  Shadow
//
//  Created by Aditi on 24/07/17.
//  Copyright © 2017 Atinderjit Kaur. All rights reserved.
//

import UIKit

class SideMenuBarViewController: UIViewController {

    @IBOutlet var tbl_View: UITableView!
    
    fileprivate var array_sideBarItems = ["Shadow Me","Edit Profile","Help","Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tbl_View.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }

 
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationItem.hidesBackButton = true
        
    }
    
    //MARK:Button Actions
    
    @IBAction func Action_Switch(_ sender: UISwitch) {
        
        self.showAlert(Message: "Coming soon", vc: self)
        
    }
    
    @IBAction func Action_Back(_ sender: UIButton) {
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}

extension SideMenuBarViewController:UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array_sideBarItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SideMenuTableViewCell
        
        cell.lbl_ItemName.text = self.array_sideBarItems[indexPath.row]
        
        if cell.isSelected {
            cell.lbl_ItemName.textColor = Global.macros.themeColor
        } else {
            // change color back to whatever it was
            cell.lbl_ItemName.textColor = UIColor.black
        }

        //hiding switch button
        switch indexPath.row {
        case 0:
            DispatchQueue.main.async {
                cell.btn_Switch.isHidden = false
                cell.btn_Switch.isOn = false
                
            }
            break
        default:
            DispatchQueue.main.async {
                cell.btn_Switch.isHidden = true
            }
            
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tbl_View.cellForRow(at: indexPath) as! SideMenuTableViewCell
        cell.lbl_ItemName.textColor = Global.macros.themeColor_pink
        
        //tbl_View.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)

        let role = SavedPreferences.value(forKey: Global.macros.krole) as? String
        switch indexPath.row {
        
        //Shadow me
        case 0:
            
            DispatchQueue.main.async{
                self.showAlert(Message: "Coming Soon", vc: self)
            }
            break
        //Edit profile
        case 1:
            
            DispatchQueue.main.async {
                
                if role == "USER"{
                   self.performSegue(withIdentifier: "sideBar_to_EditProfileUser", sender: self)
                }
                else{
                    print("Yes")
                    self.performSegue(withIdentifier: "sideBar_to_EditProfileC", sender: self)
                }
            }
           
        //Help
        case 2:
            DispatchQueue.main.async{
                self.showAlert(Message: "Coming Soon", vc: self)
            }
            break
       
        //LogOut
        case 3:
            
            let dict = NSMutableDictionary()
            let  user_Id = SavedPreferences.value(forKey: Global.macros.kUserId) as? NSNumber
            dict.setValue(user_Id, forKey: Global.macros.kUserId)
            
            
            let TitleString = NSAttributedString(string: "Shadow", attributes: [
                NSFontAttributeName : UIFont.systemFont(ofSize: 18),
                NSForegroundColorAttributeName : Global.macros.themeColor_pink
                ])
            let MessageString = NSAttributedString(string: "Are you sure you want to log Out?", attributes: [
                NSFontAttributeName : UIFont.systemFont(ofSize: 15),
                NSForegroundColorAttributeName : Global.macros.themeColor_pink
                ])
            
            DispatchQueue.main.async {
                self.clearAllNotice()
                
                let alert = UIAlertController(title: "Shadow", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "Yes", style: .default, handler: { (alert) in
                    
                    if self.checkInternetConnection()
                    {
                        DispatchQueue.main.async {
                            self.pleaseWait()
                        }
                        AuthenticationAPI.sharedInstance.LogOut(dict: dict, completion: {(response) in
                            
                            DispatchQueue.main.async {
                                self.clearAllNotice()
                                
                                
                                bool_fromMobile = false
                                bool_NotVerified = false
                                bool_LocationFilter = false
                                bool_PlayFromProfile = false
                                bool_AllTypeOfSearches = false
                                bool_CompanySchoolTrends = false
                                bool_fromVerificationMobile = false
                                bool_UserIdComingFromSearch = false
                                video_url = nil
                                
                                SavedPreferences.set(nil, forKey: "user_verified")
                                SavedPreferences.set(nil, forKey: "sessionToken")
                                SavedPreferences.removeObject(forKey: Global.macros.kUserId)
                                let vc = Global.macros.Storyboard.instantiateViewController(withIdentifier: "Login")
                                Global.macros.kAppDelegate.window?.rootViewController = vc
                                
                            }
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
                }))
                
                alert.addAction(UIAlertAction.init(title: "No", style: .default, handler:nil))
                alert.view.layer.cornerRadius = 10.0
                alert.view.clipsToBounds = true
                alert.view.backgroundColor = UIColor.white
                alert.view.tintColor = Global.macros.themeColor_pink
                
                alert.setValue(TitleString, forKey: "attributedTitle")
                alert.setValue(MessageString, forKey: "attributedMessage")
                self.present(alert, animated: true, completion: nil)
                
            }
            
            break
            
        default:
            break
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let cell = tbl_View.cellForRow(at: indexPath ) as! SideMenuTableViewCell
        
        // change color back to whatever it was
        cell.lbl_ItemName.textColor = UIColor.black
        tbl_View.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)

    }
    
   
    
    
    
    
    
   
}
