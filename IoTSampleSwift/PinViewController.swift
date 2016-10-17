/*
* Copyright 2010-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

import UIKit
import AWSIoT

class PinViewController: UIViewController, UITableViewDelegate, TableViewRefreshProtocol {
    
    //MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl:UIRefreshControl!
    
    var pinDataSource = PinTableViewSource()
    
    //MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Set up the Refresh delegate so the when the data loads the tableview is refreshed
        
        pinDataSource.tableViewRefreshDelegate = self
        
        tableView.delegate = self
        tableView.dataSource = pinDataSource
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(PinViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: TableViewRefreshProtocol
    
    func refresh(sender : AnyObject) {
        
        pinDataSource.loadData()
        
        refreshView(sender)
        
    }
    
    //MARK: Refresh the pin table view to get the initial pin status (on or off) and align the pin Switch to that state
    
    func refreshView(sender : AnyObject) {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        })
    }
    
    
}
