//
//  NotificationsViewController.swift
//  Shadow
//
//  Created by Aditi on 26/07/17.
//  Copyright © 2017 Atinderjit Kaur. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var tblView_Notifications: UITableView!
    @IBOutlet var lbl_NoNotifications: UILabel!
    
    fileprivate var array_allNotifications = NSMutableArray()
    fileprivate var item_trash = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.navigationItem.title = "Notifications"
            self.navigationItem.setHidesBackButton(false, animated:true)
            self.CreateNavigationBackBarButton()
            self.getAllNotifications()
            
            //navigation clear button
            let btn_trash = UIButton(type: .custom)
            btn_trash.setImage(UIImage(named: "trash"), for: .normal)
            btn_trash.frame = CGRect(x: self.view.frame.size.width - 20, y: 0, width: 20, height: 25)
            btn_trash.addTarget(self, action: #selector(self.btn_Clear), for: .touchUpInside)
            self.item_trash = UIBarButtonItem(customView: btn_trash)
            self.navigationItem.setRightBarButtonItems([self.item_trash], animated: true)
            
            //adding view to table footer
            self.tblView_Notifications.tableFooterView = UIView()
            
            
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: -  Functions
    
  fileprivate func getAllNotifications(){
    
        let dict = NSMutableDictionary()
        dict.setValue(SavedPreferences.value(forKey: Global.macros.kUserId) as? NSNumber, forKey: Global.macros.kUserId)
        print(dict)
        
        if self.checkInternetConnection(){
            
            DispatchQueue.main.async {
                self.pleaseWait()
            }
            
            
            Notification_API.sharedInstance.retrieveNotifications(dict: dict, completionBlock: { (response) in
                print(response)
                DispatchQueue.main.async {
                    self.clearAllNotice()
                }
                let status = response.value(forKey: "status") as? NSNumber
                switch(status!){
                    
                case 200:
                    
                    self.array_allNotifications = (response.value(forKey: "data") as! NSArray).mutableCopy() as! NSMutableArray
                    DispatchQueue.main.async {
                        self.tblView_Notifications.isHidden = false
                        self.tblView_Notifications.reloadData()
                        self.lbl_NoNotifications.isHidden = true
                        self.item_trash.isEnabled = true
                        self.tblView_Notifications.reloadData()
                    }
                    
                    break
                    
                case 404:
                    DispatchQueue.main.async {
                        self.tblView_Notifications.isHidden = true
                        self.lbl_NoNotifications.isHidden = false
                        self.item_trash.isEnabled = false
                    }
                    
                    break
                    
                default:
                    self.showAlert(Message: Global.macros.kError, vc: self)
                    break
                    
                    
                }
                
            }, errorBlock: { (error) in
                DispatchQueue.main.async {
                    self.clearAllNotice()
                    self.showAlert(Message: Global.macros.kError, vc: self)
                }
            })
        }else{
            self.showAlert(Message: Global.macros.kInternetConnection, vc: self)
        }
    }
    
    
  @objc fileprivate func btn_Clear(){
        
        let dict = NSMutableDictionary()
        dict.setValue(SavedPreferences.value(forKey: Global.macros.kUserId) as? NSNumber, forKey: Global.macros.kUserId)
        print(dict)
        
        if self.checkInternetConnection(){
            
            DispatchQueue.main.async {
                self.pleaseWait()
            }
            
            Notification_API.sharedInstance.clearNotifications(dict: dict, completionBlock: { (response) in
                print(response)
                
                DispatchQueue.main.async {
                    self.clearAllNotice()
                }
                let status = response.value(forKey: "status") as? NSNumber
                switch(status!){
                    
                case 200:
                    
                    self.array_allNotifications.removeAllObjects()
                    DispatchQueue.main.async {
                        self.tblView_Notifications.reloadData()
                        self.tblView_Notifications.isHidden = true
                        self.lbl_NoNotifications.isHidden = false
                    }
                    
                    break
                    
                case 404:
                    DispatchQueue.main.async {
                        
                        self.showAlert(Message: "Already cleared", vc: self)
                        self.tblView_Notifications.isHidden = true
                        self.lbl_NoNotifications.isHidden = false
                    }
                    
                    break
                    
                default:
                    self.showAlert(Message: Global.macros.kError, vc: self)
                    break
                    
                    
                }
                
            }, errorBlock: { (error) in
                DispatchQueue.main.async {
                    self.clearAllNotice()
                    self.showAlert(Message: Global.macros.kError, vc: self)
                }
            })
            
            

        }else{
            self.showAlert(Message: Global.macros.kInternetConnection, vc: self)
        }
        
    }
    
    
    
    //MARK: - UITableview Datasource and delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NotificationTableViewCell
        
        cell.dataToCell(dict: self.array_allNotifications.object(at: indexPath.row) as! NSDictionary)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.array_allNotifications.count
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let requestID = (array_allNotifications.object(at: indexPath.row) as! NSDictionary).value(forKey: "id") as? NSNumber
  
        print(requestID!)
        
        let vc = Global.macros.Storyboard.instantiateViewController(withIdentifier: "Request_Details") as! RequestDetailsViewController
//        vc.user_Name =  self.navigationItem.title
//        vc.request_id_fromRequestDetail = requestID!
//        vc.check_comingFromRequestDetail = "YES"
       // userIdFromSearch = Dict_Info.value(forKey: Global.macros.kotherUserId) as? NSNumber
        _ = self.navigationController?.pushViewController(vc, animated: true)
        
        
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
