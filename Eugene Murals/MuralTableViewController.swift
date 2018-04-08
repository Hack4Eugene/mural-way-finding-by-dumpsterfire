//
//  MuralTableViewController.swift
//  Eugene Murals
//
//  Created by Andrew on 3/25/18.
//  Copyright © 2018 Andrew Nordahl. All rights reserved.
//

import UIKit

class MuralTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.shadowImage = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return MuralManager.sharedInstance.murals.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "muralCell", for: indexPath) as! MuralTableViewCell
        let currentMural = MuralManager.sharedInstance.murals[indexPath.row]
        cell.backgroundImage.image = currentMural.image
        cell.muralNameLabel.text = currentMural.name
        cell.artistNameLabel.text = currentMural.artist

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let loginStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = loginStoryboard.instantiateViewController(withIdentifier: "muralDetails") as! MuralDetailViewController
        viewController.mural = MuralManager.sharedInstance.murals[indexPath.row]
        show(viewController, sender: self)
    }

}
