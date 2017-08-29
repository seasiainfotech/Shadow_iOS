//
//  SendRequestViewController.swift
//  Shadow
//
//  Created by Aditi on 18/08/17.
//  Copyright © 2017 Atinderjit Kaur. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces
import GooglePlacePicker

class SendRequestViewController: UIViewController,GMSAutocompleteViewControllerDelegate {

    @IBOutlet var imgView_InPerson: UIImageView!
    @IBOutlet var btn_SelectLocation: UIButton!
    @IBOutlet var imgView_Virtually: UIImageView!
    @IBOutlet var btn_SelectVirtualOption: UIButton!
    @IBOutlet var calender: FSCalendar!
    @IBOutlet var txtView_Message: UITextView!
    @IBOutlet var lbl_MessagePlaceholder: UILabel!
    @IBOutlet var k_Constraint_ScroolViewTop: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!
    
    var user_Name:String?
    
    fileprivate var str_date_selected:String? = ""
    
    override func viewWillLayoutSubviews() {
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 700)
    }
    
    //Converts string into date
    let formatter: DateFormatter =
        {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            
            self.navigationItem.title = self.user_Name!
            self.btn_SelectLocation.layer.cornerRadius = 3.0
            self.btn_SelectLocation.layer.borderColor = Global.macros.themeColor_pink.cgColor
            self.btn_SelectLocation.layer.borderWidth = 1.0
            
            self.btn_SelectVirtualOption.layer.cornerRadius = 3.0
            self.btn_SelectVirtualOption.layer.borderColor = Global.macros.themeColor_pink.cgColor
            self.btn_SelectVirtualOption.layer.borderWidth = 1.0
            
            
            self.txtView_Message.layer.cornerRadius = 5.0
            self.txtView_Message.layer.borderWidth = 1.0
            self.txtView_Message.layer.borderColor = Global.macros.themeColor.cgColor
            
            
            self.CreateNavigationBackBarButton()
            
            
            //Adding button to navigation bar
            let btn2 = UIButton(type: .custom)
            btn2.setImage(UIImage(named: "send_white"), for: .normal)
            btn2.frame = CGRect(x: self.view.frame.size.width - 25, y: 0, width: 25, height: 25)
            btn2.addTarget(self, action: #selector(self.Send), for: .touchUpInside)
            let item2 = UIBarButtonItem(customView: btn2)
            //Right items
            self.navigationItem.setRightBarButtonItems([item2], animated: true)

        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Button Actions
    @IBAction func Action_CheckBtnLocation(_ sender: UIButton) {
        
        self.imgView_InPerson.image = UIImage.init(named: "checked")
        self.imgView_Virtually.image = UIImage.init(named: "unchecked")
        
        self.btn_SelectLocation.isHidden = false
      //  self.btn_SelectVirtualOption.isHidden = true

        
        
    }
    
    @IBAction func Action_CheckBtnVirtualOption(_ sender: UIButton) {
        
        self.imgView_Virtually.image = UIImage.init( named: "checked")
        self.imgView_InPerson.image = UIImage.init(named: "unchecked")

        self.btn_SelectLocation.isHidden = true
     //   self.btn_SelectVirtualOption.isHidden = false
    }
    

    @IBAction func Action_SelectLocation(_ sender: Any) {
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
        
    }
    
    @IBAction func Action_SelectVirtualOption(_ sender: UIButton) {
        
        self.showAlert(Message: "Coming Soon", vc: self)
    }
    
   //MARK: - Functions
    
    func Send(){
        
        txtView_Message.resignFirstResponder()
        if self.imgView_Virtually.image == UIImage.init(named: "checked") || self.imgView_InPerson.image == UIImage.init(named: "checked"){
            if str_date_selected != ""{
                if txtView_Message.text != ""  {
                    
                    if self.checkInternetConnection(){
                        
                        DispatchQueue.main.async {
                            self.pleaseWait()
                        }

                        
                        let dict = NSMutableDictionary()
                        
                        let  user_Id = SavedPreferences.value(forKey: Global.macros.kUserId) as? NSNumber
                        dict.setValue(user_Id, forKey: Global.macros.kUserId)
                        dict.setValue(userIdFromSearch, forKey:Global.macros.kotherUserId)

                        if imgView_InPerson.image == UIImage.init(named: "checked"){
                            dict.setValue(btn_SelectLocation.currentTitle, forKey: Global.macros.k_location)

                        }
                        else if  imgView_Virtually.image == UIImage.init(named: "checked"){
                            //dict.setValue(btn_SelectVirtualOption.currentTitle, forKey: Global.macros.k_mediumOfCommunication)
                            
                            dict.setValue("Video Call", forKey: Global.macros.k_mediumOfCommunication)

                        }
                        
                        dict.setValue(str_date_selected!, forKey: Global.macros.k_SelectedDate)
                        dict.setValue(txtView_Message.text!, forKey: Global.macros.k_message)
                        print(dict)
                        
                        Requests_API.sharedInstance.sendRequest(completionBlock: { (status, dict_Info) in
                            
                            DispatchQueue.main.async {
                                self.clearAllNotice()
                            }
                            
                            switch status {
                                
                            case 200:
                                
                                DispatchQueue.main.async {
                                    
                                    self.showAlert(Message: "Request successfully sent.", vc: self)
                                    _ = self.navigationController?.popToRootViewController(animated: true)
                                }

                                break
                                
                            case 400:
                                DispatchQueue.main.async {

                                 self.showAlert(Message: "Your previous request is pending.", vc: self)
                                  _ = self.navigationController?.popToRootViewController(animated: true)
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

                        }, dict: dict)
                        
                        
                    }else{
                        
                        self.showAlert(Message:Global.macros.kInternetConnection, vc: self)
                    }
                }else{
                    self.showAlert(Message: "Please write some message.", vc: self)
                }
            }
            else{
                self.showAlert(Message: "Please select a date.", vc: self)
            }
           
        }else{
            self.showAlert(Message: "Please select atleast one option to meet.", vc: self)
        }
    }
    
    
    // MARK: - Delegate GMSAutocompleteViewController
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        self.btn_SelectLocation.setTitle(place.name, for: .normal)
        dismiss(animated: true, completion: nil)
   
    }
    
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        //  handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
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

extension SendRequestViewController:UITextViewDelegate{
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n"
        {
            textView.resignFirstResponder()
        }
        return true
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        lbl_MessagePlaceholder.isHidden = true
        
        if Global.DeviceType.IS_IPHONE_5 || Global.DeviceType.IS_IPHONE_6{
            DispatchQueue.main.async {
                
                 self.animateTextView(textView: textView, up: true, movementDistance: textView.frame.maxY, scrollView:self.scrollView)
                
                UIView.animate(withDuration: 1.0, animations: {
                    //self.k_Constraint_ScroolViewTop.constant = -170.0
                    
                })
            }
            
            
        }
        if Global.DeviceType.IS_IPHONE_4_OR_LESS{
            DispatchQueue.main.async {
                UIView.animate(withDuration: 1.0, animations: {
                    //self.k_Constraint_ScroolViewTop.constant = -200
                })
            }
        }
    }

    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        let str = textView.text.trimmingCharacters(in: .whitespaces)
        
        if str == ""
        {
            self.txtView_Message.text = ""
            lbl_MessagePlaceholder.isHidden = false
            
        }
        else{
            txtView_Message.text = textView.text
        }
        
        if Global.DeviceType.IS_IPHONE_5{
            DispatchQueue.main.async {
                
                 self.animateTextView(textView: textView, up: false, movementDistance: textView.frame.minY, scrollView:self.scrollView)
                
                UIView.animate(withDuration: 1.0, animations: {
                    //self.k_Constraint_ScroolViewTop.constant = 0.0
                })
            }
            
            
        }
        if Global.DeviceType.IS_IPHONE_4_OR_LESS{
            DispatchQueue.main.async {
                UIView.animate(withDuration: 1.0, animations: {
                    //self.k_Constraint_ScroolViewTop.constant = 0.0
                })
            }
            
            
        }
    }

}
extension SendRequestViewController:FSCalendarDelegate,FSCalendarDataSource{
    
    
    //Called when available date is selected
    func calendar(_ calendar: FSCalendar, didSelect date: Date) {
        
        
        if date <= calendar.today!
        {
            calender.deselect(date)
            self.showAlert(Message: "Please select future date.", vc: self)
            return
        }
        else{
            
            str_date_selected = (self.formatter.string(from: date))
            
        }
        
    }
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        
        if date == calender.today
        {
            return "Today"
        }
        else{
            return nil
        }
    }

}
