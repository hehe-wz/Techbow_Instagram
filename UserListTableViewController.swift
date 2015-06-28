//
//  UserListTableViewController.swift
//  ParseStarterProject
//
//  Created by Zun Wang on 6/26/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

extension Array {
  func removeUserID(idToRemove: String) -> [PFUser] {
    var filterUserList = [PFUser]()
    var arrayElement: T
    for arrayElement in self {
      if let user = arrayElement as? PFUser where user.objectId != idToRemove {
        filterUserList.append(user)
      }
    }
    return filterUserList
  }
}

class UserListTableViewController: UITableViewController, UITableViewDelegate {
  
  var userList = [PFUser]()
  var followeeList = Set<String>()
  let refresher = UIRefreshControl()
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let feedTableVC = segue.destinationViewController as? FeedTableViewController where segue.identifier == "showFeedSegue" {
      feedTableVC.userIdList = Array<String>(followeeList)
    }
  }
  
  override func viewDidLoad() {
    refresher.attributedTitle = NSAttributedString(string:"Pull to refresh")
    refresher.addTarget(self, action: "didPullToRefresh", forControlEvents: UIControlEvents.ValueChanged)
    self.tableView.addSubview(refresher)
    
    self.tableView.tableFooterView = nil
    self.didPullToRefresh()
  }
  
//  override func viewWillAppear(animated: Bool) {
//    super.viewWillAppear(animated)
//  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return userList.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("userListCell", forIndexPath: indexPath) as! UITableViewCell
    cell.textLabel?.text = userList[indexPath.row].username
    if followeeList.contains(userList[indexPath.row].objectId!) {
      cell.accessoryType = UITableViewCellAccessoryType.Checkmark
    }
  
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    var cell = self.tableView.cellForRowAtIndexPath(indexPath)
    let currentUserID = PFUser.currentUser()!.objectId!
    let followeeID = userList[indexPath.row].objectId!
    if (cell?.accessoryType == UITableViewCellAccessoryType.None) {
      cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
      var followers = PFObject(className:"Follow")
      followers["followee"] = followeeID
      followers["follower"] = currentUserID
      followers.saveInBackground()
      followeeList.insert(followeeID)
    } else {
      cell?.accessoryType = UITableViewCellAccessoryType.None
      let followQuery = PFQuery(className: "Follow")
      followQuery.whereKey("follower", equalTo: currentUserID)
      followQuery.whereKey("followee", equalTo: followeeID)
      followQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
        PFObject.deleteAllInBackground(objects)
      })
      followeeList.remove(followeeID)
    }
  }
  
  private func didPullToRefresh() {
    let query = PFUser.query()
    query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
      if let users = objects as? [PFUser] {
        let currentUserID = PFUser.currentUser()!.objectId!
        
//        self.userList = users.removeUserID(currentUserID)
        self.userList = users.filter({(user: PFUser) -> Bool in user.objectId != currentUserID })
        
        // Get followee List
        let followeesQuery = PFQuery(className: "Follow")
        followeesQuery.whereKey("follower", equalTo: currentUserID)
        followeesQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
          if let followees = objects as? [PFObject] {
            self.followeeList = Set(followees.map({(followee: PFObject) -> String in followee.objectForKey("followee") as! String }))
            self.tableView.reloadData()
          } else {
            println("Error: \(error!) \(error!.userInfo!)")
          }
          self.refresher.endRefreshing()
        })
      } else {
        println("Error: \(error!) \(error!.userInfo!)")
        self.refresher.endRefreshing()
      }
    })
  }
}
