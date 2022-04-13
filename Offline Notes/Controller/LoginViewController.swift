//
//  LoginViewController.swift
//  Offline Notes
//
//  Created by Vansh Bhatia on 4/12/22.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {


    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.title = "Login"
    }

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!


    var phoneNumber: String?

    //MARK: - Method called when login button pressed
    @IBAction func loginButtonPressed(_ sender: UIButton) {

        if let userName = usernameTextField.text, let password = passwordTextField.text {
            var userArray = [User]()
            let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
            do {
                let newArr = try context.fetch(fetchReq) as! [User]
                print(newArr)
                userArray = newArr


            } catch let error {
                print(error.localizedDescription)
                return
            }
            // check if the username exists, if so, decrypt password
            print(userArray)
            for user in userArray {
                if user.email == userName || user.phoneNumber == userName {
                    let decryptedPass = decryptPass(with: user.key!, oldPassword: user.encyptedPwd!)
                    if decryptedPass == password {
                        print("password verifed")
                        phoneNumber = user.phoneNumber!

                        performSegue(withIdentifier: "logInToListVC", sender: self)
                    }
                }
            }

        }

    }


    //MARK: - Method to decrypt password from key
    func decryptPass(with key: String, oldPassword encryptedPass: String) -> String {
        let alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var password = ""
        for char in encryptedPass {
            let c = Character(char.uppercased())
            if let index = key.firstIndex(of: c) {
                let newVal = alphabets[index]
                if c == char {
                    password += String(newVal)
                }
                else {
                    password += String(newVal.lowercased())
                }
            }
            else {
                password += String(char)
            }
        }
        return password
    }

    //MARK: - Method to prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let lvc = segue.destination as? ListViewController {
            lvc.currentUser = phoneNumber ?? "9000000000"
        }
    }
}
