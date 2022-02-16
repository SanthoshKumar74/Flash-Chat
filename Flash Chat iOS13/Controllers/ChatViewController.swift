//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    let db = Firestore.firestore()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    var messages: [Messages] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = K.appName
        navigationItem.hidesBackButton = true
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        loadMessages()
        
    }
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
          
        
    }
    @IBAction func sendPressed(_ sender: UIButton) {
        
        if let messagebody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email {
            
            db.collection(K.FStore.collectionName).addDocument(data: [K.FStore.senderField : messageSender,K.FStore.bodyField: messagebody,K.FStore.dateField:Date().timeIntervalSince1970]) {(error) in
                if let e = error{
                    print("Firestore Error\(e)")
                }
            }
        }
   
        
    }
    func loadMessages(){
        db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).addSnapshotListener{ querysnapshot, error in
            self.messages = []
            if let e = error{
                print("\(e)")
            }else{
                if let snapshot = querysnapshot?.documents{
                    for doc in snapshot{
                        let data = doc.data()
                        if  let sender = data[K.FStore.senderField] as? String, let body = data[K.FStore.bodyField] as? String{
                           let message = Messages(sender: sender, body: body)
                            self.messages.append(message)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .top, animated: true)
                            }
                        }
                        
                    }
                    
                }
            }
            
        }
    }

}

extension ChatViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
            cell.label.text = message.body
        if message.sender == Auth.auth().currentUser?.email{
            cell.rightImageView.isHidden = true
            cell.leftImageView.isHidden = false
            cell.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            
        }else{
            cell.rightImageView.isHidden = false
            cell.leftImageView.isHidden = true
            cell.backgroundColor = UIColor(named: K.BrandColors.lighBlue)
            
        }
        
        return cell
    }
    
    
}

