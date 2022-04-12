//
//  ViewController.swift
//  Offline Notes
//
//  Created by Vansh Bhatia on 4/11/22.
//

import UIKit
import CoreData

class NotesViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate {

    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var imageSubmitButton: UIButton!
    
    var noteTitle:String?
    var descText:String?
    var img:UIImage?
    var oldNote:Note?
    var currentUser:String? = "9000000000"
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        titleField.delegate = self
        descriptionField.delegate = self
        
        titleField.text = noteTitle ?? "Untitled"
        navigationItem.title = titleField.text
        descriptionField.text = descText ?? ""
        imageView.image = img ?? .none
    }

    
    // MARK: - Method called when tap Button is pressed to add image
    @IBAction func didTapButton(_ sender: UIButton) {

        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        
        vc.delegate = self
        vc.allowsEditing = true

        present(vc, animated: true)

    }

    
    // MARK: - ImagePickerController delegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            imageView.image = image
            imageSubmitButton.setTitle("Edit or Select New Image", for: .normal)
        }
        dismiss(animated: true)

    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    // MARK: - Method called when saveButton is pressed
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        
        if let png = imageView.image?.pngData(), let title = titleField.text, let desc = descriptionField.text, let user = currentUser{
            saveData(user: user, title: title, description: desc, image: png)
            print("saved with user \(user)")
            navigationController?.popViewController(animated: true)
        }
        
        
    }
    
    // MARK: - Method used to save data to CoreData
    
    func saveData(user:String, title:String, description:String, image: Data){
        let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
        note.uploadedUser = user
        note.title = title
        note.info = description
        note.img = image
        
        do{
            try context.save()
        }catch let error{
            print(error.localizedDescription)
        }
        
        if let n = oldNote{
            context.delete(n)
            do{
                try context.save()
            }catch let error{
                print(error.localizedDescription)
            }
        }
        
    }
    
    
    //MARK: - Methods to collapse Keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
}

