//
//  NotesViewController.swift
//  Nota
//
//  Created by mahmoud mohamed on 7/12/19.
//  Copyright © 2019 Robusta. All rights reserved.
//

import UIKit
import Firebase
import CodableFirebase

class NotesViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var notesTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var numberOfNotesLabel: UILabel!
    
    let noteCellNib = UINib(nibName: "NoteTableViewCell", bundle: nil)
    let noteCellReuseId = "noteCell"
    var notes:[Note] = []
    var currentUserId:String!
    var databaseRef:DatabaseReference!
    var mappedNotesIds:[String:String] = [:]
    var selectedRow:IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference()
        self.configViews()
        self.observeNotesChanges()
        self.observeNotesModifications()
        self.setupNavigationBar()
        self.currentUserId = Auth.auth().currentUser?.uid
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
    
    func configViews(){
        self.activityIndicator.stopAnimating()
        self.notesTableView.register(noteCellNib, forCellReuseIdentifier: noteCellReuseId)
    }
    
    func setupNavigationBar(){
        self.navigationItem.title = "Notes"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        let addNoteBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
        addNoteBarButtonItem.tintColor = .black
        self.navigationItem.rightBarButtonItem = addNoteBarButtonItem
    }
    
    func observeNotesChanges(){
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
        databaseRef.child("Notes").queryOrdered(byChild: "ownerId").queryEqual(toValue: "1").observe(.value) { (snapshot) in
            self.handleChangesResponse(snapshot)
        }
    }
    
    func observeNotesModifications(){
        databaseRef.child("Notes").queryOrdered(byChild: "ownerId").queryEqual(toValue: "1").observe(.childChanged) { (snapshot) in
            print("🔵🔵 child changed")
            if snapshot.value is NSNull{
                self.presentAlert(title: "Error fetching notes changes", message: nil)
                return
            }
            DispatchQueue.main.async {
                let cell = self.notesTableView.cellForRow(at: self.selectedRow) as! NoteTableViewCell
                let noteData = try? FirebaseDecoder().decode(Note.self, from: snapshot.value!)
                cell.configureCell(title: noteData!.content)
            }
        }
    }
    
    fileprivate func handleChangesResponse(_ snapshot: DataSnapshot) {
        if snapshot.value is NSNull{
            print("Error observing changes 🔴")
            self.presentAlert(title: "Cannot fetch account notes", message: nil)
            return
        }
        print("changes observed 🚘")
        let noteDataDictionary = (snapshot.value) as? [String:Any] ?? [:]
        var notesMap:[String:String] = [:]
        for note in noteDataDictionary{
            let key = note.key
            let noteValue = try? FirebaseDecoder().decode(Note.self, from: note.value)
            if noteValue != nil{
                notesMap[key] = noteValue!.noteId
                print("Map: \(notesMap)")
            }
        }
        self.mappedNotesIds = notesMap
        print(self.mappedNotesIds)
        let noteData = ((snapshot.value) as? [String:Any])?.values
        print("🎭 \(noteData)")
        do{
            for note in noteData!{
                let note = try FirebaseDecoder().decode(Note.self, from: note)
                print("Note: \(note)")
                if !self.isContained(noteToCheck: note){
                    self.notes.append(note)
                    self.notesTableView.insertRows(at: [IndexPath(row: self.notes.count-1, section: 0)], with: .automatic)
                    print("Number of notes: \(self.notes.count)")
                }
            }
        }
        catch{
            self.presentAlert(title: "Cannot Display incoming notes.", message: nil)
            print(error)
            return
        }
        DispatchQueue.main.async {
            self.numberOfNotesLabel.text = "\(self.notes.count) Notes"
            self.activityIndicator.stopAnimating()
        }
    }
    
    func isContained(noteToCheck:Note)->Bool{
        for note in self.notes{
            if note.noteId == noteToCheck.noteId{
               return true
            }
        }
        return false
    }
    
    
    @objc func addNote(){
        let addNoteVC = AddNoteViewController()
        addNoteVC.isNewNote = true
        addNoteVC.currentUserId = self.currentUserId
        self.navigationController?.pushViewController(addNoteVC, animated: true)
    }
    
    func presentAlert(title:String?,message:String?){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert,animated: true)
    }

}

extension NotesViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: noteCellReuseId, for: indexPath) as! NoteTableViewCell
        cell.configureCell(title: self.notes[self.notes.count-1].content)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(tableView.frame.size.height/8)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedRow = indexPath
        let addNoteVC = AddNoteViewController()
        addNoteVC.isNewNote = false
        addNoteVC.currentNote = self.notes[indexPath.row]
        addNoteVC.mappedNotesIds = self.mappedNotesIds
        print("Selected note: \(self.notes[indexPath.row].content)")
        self.navigationController?.pushViewController(addNoteVC, animated: true)
    }
    
}
