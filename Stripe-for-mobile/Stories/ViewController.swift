//
//  ViewController.swift
//  Stripe-for-mobile
//
//  Created by Sadrul on 9/5/16.
//  Copyright © 2016 Asif. All rights reserved.
//

import UIKit
import Stripe
import AFNetworking

class ViewController: UIViewController {

  @IBOutlet weak var txtFldEmail: UITextField!
  @IBOutlet weak var txtFldCardNumber: UITextField!
  @IBOutlet weak var txtFldExpireDate: UITextField!
  @IBOutlet weak var txtFldCVC: UITextField!
  @IBOutlet weak var txtFldAmount: UITextField!
  var expMonth = UInt()
  var expYear  = UInt()
  var stripCardParams = STPCardParams()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  @IBAction func sendBtnAction(sender: AnyObject) {
    // Split the expiration date to extract Month & Year
    if self.txtFldExpireDate.text!.isEmpty == false {
      splitDate()
      getCardInfo()
      validateSTPCardForParams(stripCardParams)
      STPAPIClient.sharedClient().createTokenWithCard(stripCardParams, completion: { (token, error) -> Void in
        if error != nil {
          print ("Error")
           self.handleError(error!)
          return
        }
        print("Token here : \(token)")
        self.postStripeToken(token!)
      })
    }
  }
  
    func handleError(error: NSError) {
        UIAlertView(title: "Please Try Again",
                    message: error.localizedDescription,
                    delegate: nil,
                    cancelButtonTitle: "OK").show()
        
    }
    
    func postStripeToken(token: STPToken) {
        
        let URL = "http://localhost/donate/payment.php"
        let params = ["stripeToken": token.tokenId,
                      "amount": 100,
                      "currency": "usd",
                      "description": "hello"]
        
        let manager = AFHTTPRequestOperationManager()
        manager.POST(URL, parameters: params, success: { (operation, responseObject) -> Void in
            
            if let response = responseObject as? [String: String] {
                UIAlertView(title: response["status"],
                    message: response["message"],
                    delegate: nil,
                    cancelButtonTitle: "OK").show()
            }
            
        }) { (operation, error) -> Void in
            //self.handleError(error!)
            print("Error Took Place")
        }
    }
    
    
  // Send the card info to Strip to get the token
  func getCardInfo(){
    stripCardParams.number = self.txtFldCardNumber.text
    stripCardParams.cvc = self.txtFldCVC.text
    stripCardParams.expMonth = expMonth
    stripCardParams.expYear = expYear
  }
  
  func splitDate(){
    let expirationDate = self.txtFldExpireDate.text!.componentsSeparatedByString("/")
     expMonth = UInt(Int(expirationDate[0])!)
     expYear = UInt(Int(expirationDate[1])!)
  }
  
  func validateSTPCardForParams(stripCardParams : STPCardParams){
    if STPCardValidator.validationStateForCard(stripCardParams) == .Valid {
      //notifyCardValidation("Validation Succeed!")
      clearInputValues()
    }
    else{
      //handleError("Invalid Card")
    }
  }
  
  func clearInputValues () {
    txtFldEmail.text = ""
    txtFldCVC.text = ""
    txtFldCardNumber.text = ""
    txtFldExpireDate.text = ""
    txtFldEmail.text = ""
    txtFldAmount.text = ""
    txtFldAmount.resignFirstResponder()
  }
  
  func notifyCardValidation(validationMsg: NSString) {
    UIAlertView(title: "Congrates",
                message: validationMsg as String,
                delegate: nil,
                cancelButtonTitle: "OK").show()
  }
  

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

