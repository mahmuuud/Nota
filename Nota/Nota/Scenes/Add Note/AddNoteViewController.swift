//
//  AddNoteViewController.swift
//  Nota
//
//  Created by mahmoud mohamed on 7/12/19.
//  Copyright © 2019 Robusta. All rights reserved.
//

import UIKit
import Firebase
import CodableFirebase

class AddNoteViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var noteTextView: UITextView!
    
    var isNewNote:Bool!
    var currentUserId:String!
    var currentNote:Note!
    var databaseRef:DatabaseReference!
    var mappedNotesIds:[String:String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configViews()
        self.setupNavigationBar()
    }

    func setupNavigationBar(){
        self.navigationController?.navigationBar.prefersLargeTitles = false
        let saveBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveNote))
        saveBarButtonItem.tintColor = .black
        self.navigationItem.rightBarButtonItem = saveBarButtonItem
    }
    
    func configViews(){
        if !self.isNewNote{
            self.noteTextView.text = currentNote.content
        }
    }
    
    @objc func saveNote(){
        if self.isNewNote {
            self.currentNote = Note(content: self.noteTextView.text ?? "", ownerId: Auth.auth().currentUser!.uid, noteId: UUID().uuidString)
            let encodedNote = try? FirebaseEncoder().encode(self.currentNote)
            self.databaseRef.child("Notes").childByAutoId().setValue(encodedNote)
        }
        else{
            var nodeId = ""
            for note in mappedNotesIds{
                if note.value == self.currentNote.noteId{
                    nodeId = note.key
                    print("Found note 🔴")
                    break
                }
            }
            if nodeId != ""{
                print("Edited ====")
                self.databaseRef.child("Notes").child(nodeId).updateChildValues(["content":self.noteTextView.text!])
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
}
