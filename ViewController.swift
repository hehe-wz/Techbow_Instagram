//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  
  private let spinner = UIActivityIndicatorView()
  
  @IBOutlet weak var usernameTextField: UITextField!
  
  @IBOutlet weak var passwordTextField: UITextField!
  
  @IBAction func didTapPickPhotoButton(sender: UIButton) {
    var imageController = UIImagePickerController()
    imageController.delegate = self
    imageController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
    imageController.allowsEditing = false
    
    self.presentViewController(imageController, animated: true, completion: nil) // will call didFinishPickImage
  }
  
  @IBOutlet weak var imageView: UIImageView!
  
  @IBAction func didTapSignUpButton(sender: UIButton) {
    if self._checkUsernameAndPasswordNotEmpty() {
      self._setupSpinner()
      self.view.addSubview(self.spinner)
      self.view.userInteractionEnabled = false
      
      let user = PFUser()
      user.username = usernameTextField.text
      user.password = passwordTextField.text
      user.signUpInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
        if success {
          println("User '\(self.usernameTextField.text)' sign up successfully")
          self._showUserList();
        } else {
          if let error = error, errorString = error.userInfo?["error"] as? String {
            self._displayAlert("Sign up failure", message: errorString)
          }
        }
        self.spinner.stopAnimating()
        self.view.userInteractionEnabled = true
      })
    }
  }
  
  @IBAction func didTapLoginButton(sender: UIButton) {
    if self._checkUsernameAndPasswordNotEmpty() {
      PFUser.logInWithUsernameInBackground(usernameTextField.text!, password:passwordTextField.text!) {
        (user: PFUser?, error: NSError?) -> Void in
        if user != nil {
          println("User '\(self.usernameTextField.text)' login successfully")
          self._showUserList();
        } else {
          // The login failed. Check error to see why.
          if let error = error, errorString = error.userInfo?["error"] as? String {
            self._displayAlert("Login failure", message: errorString)
          }
        }
      }
    }
  }
  
  func _showUserList() {
    self.performSegueWithIdentifier("showUserList", sender: self)
  }
  
  func _checkUsernameAndPasswordNotEmpty()-> Bool {
    if self.usernameTextField.text.isEmpty || self.passwordTextField.text.isEmpty {
      self._displayAlert("Error", message: "Please enter username and password")
      return false
    }
    return true
  }
  
  func _displayAlert(title: String, message: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
  func _setupSpinner() {
    self.spinner.frame = CGRectMake(0, 0, 100, 100)
    self.spinner.center = self.view.center
    self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
    self.spinner.hidesWhenStopped = true
    self.spinner.startAnimating()
  }
  
  func _parseDataPractice() {
//    var course = PFObject(className: "Courses")
//    course["name"] = "SV iOS 003" // SV Web 004
//    course["discription"] = "App based courses, go go go"
//    course["price"] = 1999.00
//    course.saveInBackgroundWithBlock { (success, error) -> Void in
//      if success == true {
//        println("parse success")
//        println("parse object id: \(course.objectId)") // use to retrieving object data 'u5ypnVHnUu'
//      } else {
//        println("parse error: \(error)")
//      }
//    }
    
    var query = PFQuery(className: "Courses")
    
    query.whereKey("name", containsString: "SV")
    query.findObjectsInBackgroundWithBlock {
      (objects: [AnyObject]?, error: NSError?) -> Void in
      if error == nil {
        // The find succeeded.
        println("Successfully retrieved \(objects!.count) courses.")
        // Do something with the found objects
        if let objects = objects as? [PFObject] {
          for object in objects {
            println(object)
          }
        }
      } else {
        // Log details of the failure
        println("Error: \(error!) \(error!.userInfo!)")
      }
    }
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    self.dismissViewControllerAnimated(true, completion: nil)
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      imageView.image = image
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    passwordTextField.secureTextEntry = true
//    self._parseDataPractice()
  }
  
  override func viewDidAppear(animated: Bool) {
    if PFUser.currentUser()?.objectId != nil {
      self._showUserList()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

