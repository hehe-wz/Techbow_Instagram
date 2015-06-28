//
//  FeedTableViewController.swift
//  ParseStarterProject
//
//  Created by Zun Wang on 6/27/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class FeedTableViewController: UITableViewController {
  
  var userIdList = [String]() //followees
  var postList = [PFObject]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self._refreshPostData()
  }
  
  func _refreshPostData() {
    let postDataQuery = PFQuery(className: "Post")
    postDataQuery.whereKey("userId", containedIn: userIdList)
    postDataQuery.orderByDescending("createdAt")
    postDataQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
      if error != nil {
        println("Error: \(error!) \(error!.userInfo!)")
      } else if let postList = objects as? [PFObject] {
        self.postList = postList
        self.tableView.reloadData()
      }
    })
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return postList.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("feedTableViewCell", forIndexPath: indexPath) as! FeedTableViewCell
    
    if let imageFile = postList[indexPath.row]["imageFile"] as? PFFile {
      imageFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
        if error != nil {
          println("Error: \(error!) \(error!.userInfo!)")
        } else {
          cell.photoView.image = UIImage(data: data!)
        }
      })
    }
    cell.photoNameLabel.text = postList[indexPath.row]["name"] as? String
    cell.userNameLabel.text = postList[indexPath.row]["username"] as? String
    
    return cell
  }
}
