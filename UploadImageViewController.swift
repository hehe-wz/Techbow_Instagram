//
//  UploadImageViewController.swift
//  ParseStarterProject
//
//  Created by Zun Wang on 6/27/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class UploadImageViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  
  private let spinner = UIActivityIndicatorView()
  
  @IBOutlet weak var photoView: UIImageView!
  
  @IBOutlet weak var photoNameField: UITextField!
  
  @IBAction func didTapChoosePhotoButton(sender: UIButton) {
    var imageController = UIImagePickerController()
    imageController.delegate = self
    imageController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
    imageController.allowsEditing = false
    
    self.presentViewController(imageController, animated: true, completion: nil) // will call didFinishPickImage
  }
  
  @IBAction func didTapUploadPhotoButton(sender: UIButton) {
    self.spinner.startAnimating()
    self.view.userInteractionEnabled = false
    
    let imageData = UIImagePNGRepresentation(photoView.image!)
    let imageFile = PFFile(name: photoNameField.text + ".png", data: imageData)
    let post = PFObject(className: "Post")
    post["name"] = photoNameField.text
    post["userId"] = PFUser.currentUser()?.objectId
    post["username"] = PFUser.currentUser()?.username
    post["imageFile"] = imageFile
    
    post.saveInBackgroundWithBlock { (success, error) -> Void in
      if success {
        println("Photo upload success")
      } else {
        println("Error: \(error!) \(error!.userInfo!)")
      }
      self.spinner.stopAnimating()
      self.view.userInteractionEnabled = true
    }
  }
  
  @IBAction func didTapLogoutButton(sender: UIButton) {
    PFUser.logOut()
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  override func viewDidLoad() {
    self._setupSpinner()
    self.view.addSubview(self.spinner)
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    self.dismissViewControllerAnimated(true, completion: nil)
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      photoView.image = image
    }
  }
  
  func _setupSpinner() {
//    self.spinner.frame = CGRectMake(0, 0, 100, 100)
    self.spinner.frame = self.view.bounds
    self.spinner.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
    self.spinner.center = self.view.center
    self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
    self.spinner.hidesWhenStopped = true
  }
  
}
