//
//  SignUpViewController.swift
//  Offline Notes
//
//  Created by Vansh Bhatia on 4/12/22.
//

import UIKit
import CountryPickerView
import CoreData

class SignUpViewController: UIViewController, CountryPickerViewDelegate, CountryPickerViewDataSource, UITextFieldDelegate {

    //MARK: - Methods to get, format and modify country codes

    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        if country.phoneCode != "+91" {
            let alert = UIAlertController(title: "Sorry!", message: "This app is only available in India!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            present(alert, animated: true, completion: nil)
            countryPickerView.setCountryByPhoneCode("+91")
        }
    }
    func showPhoneCodeInList(in countryPickerView: CountryPickerView) -> Bool {
        return true
    }


    @IBOutlet weak var countryPicker: CountryPickerView!


    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        countryPicker.delegate = self
        countryPicker.hostViewController = self
        countryPicker.setCountryByPhoneCode("+91")
        navigationController?.title = "Sign Up"
        mobileNumberOutlet.delegate = self
        emailOutlet.delegate = self
        passwordOutlet.delegate = self
        nameOutlet.delegate = self

    }

    @IBOutlet weak var mobileNumberOutlet: UITextField!
    @IBOutlet weak var emailOutlet: UITextField!
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var nameOutlet: UITextField!

    var userArray: [User] = []
    var phoneNumber: String?

    //MARK: - Method called when button pressed to create account

    @IBAction func createAccountPressed(_ sender: UIButton) {

        if let mobile = mobileNumberOutlet.text, let name = nameOutlet.text, let password = passwordOutlet.text, let email = emailOutlet.text {
            if name == "" {
                let alert = UIAlertController(title: "Enter Name!", message: "Oops, Name cannot be blank!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
            if(!isValidEmail(email)) {
                let alert = UIAlertController(title: "Invalid Email!", message: "Oops, Looks like you entered an incorrect email!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
            if !isVaildMobile(mobile) {
                return
            }
            if(!isValidPassword(password)) {
                return
            }

            print("Correct info")


            // first load up all details of all users and check if they match with already existing email and phone numbers
            let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
            do {
                let newArr = try context.fetch(fetchReq) as! [User]
                print(newArr)
                userArray = newArr

            } catch let error {
                print(error.localizedDescription)
            }

            // iterate through the phone number and email to check if already exisits

            for user in userArray {
                if user.email == email {
                    let alert = UIAlertController(title: "Invalid Email!", message: "Oops, Looks like the email already exists!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    present(alert, animated: true, completion: nil)
                    return
                }
                if user.phoneNumber == mobile {
                    let alert = UIAlertController(title: "Invalid Email!", message: "Oops, Looks like the phone number already exists!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    present(alert, animated: true, completion: nil)
                    return
                }
            }
            // encrypt the password and save the key as well as the new string
            var alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            var key = ""
            for _ in 0..<26 {
                let rand = alphabets.randomElement()!
                key += String(rand)
                alphabets.remove(at: alphabets.firstIndex(of: rand)!)
            }
            print(key)

            let encryptedPass = encryptPass(password, key: key)


            print(encryptedPass)

            let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as! User
            user.phoneNumber = mobile
            user.email = email
            user.key = key
            user.encyptedPwd = encryptedPass
            user.name = name
            do {
                try context.save()
            } catch let error {
                print(error.localizedDescription)
            }
            phoneNumber = mobile
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "signUpToList", sender: self)
            }
            
        }
    }

    //MARK: - Methods to Validate entries

    func isVaildMobile(_ mobile: String) -> Bool {
        if mobile.count != 10 {
            let alert = UIAlertController(title: "Invalid Number!", message: "Oops, Length of mobile number should be 10!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return false
        }
        for number in mobile {
            if !"1234567890".contains(number) {
                let alert = UIAlertController(title: "Invalid Number!", message: "Oops, Incorrect mobile number!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                present(alert, animated: true, completion: nil)
                return false
            }
        }
        return true
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    func isValidPassword(_ password: String) -> Bool {
        if password.count >= 8 && password.count <= 15 {
            if(!password.contains(nameOutlet.text!)) {
                if(password.first!.isLowercase) {
                    var upperCase = 0
                    var numbers = 0
                    var symbol = 0
                    for letter in password {
                        if letter.isUppercase {
                            upperCase += 1
                        }
                        else if letter.isNumber {
                            numbers += 1
                        }
                        else if !letter.isLowercase {
                            symbol += 1
                        }
                    }
                    if upperCase >= 2 && numbers >= 2 && symbol > 0 {
                        return true
                    }
                    else {
                        // problem with special char or number or uppercase
                        let alert = UIAlertController(title: "Invalid Password!", message: "Oops, at least 2 uppercase, 2 numbers and 1 symbol!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                        present(alert, animated: true, completion: nil)
                    }

                }
                else {
                    let alert = UIAlertController(title: "Invalid Password!", message: "Oops, first char has to be lowercase!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    present(alert, animated: true, completion: nil)
                }
            }
            else {
                let alert = UIAlertController(title: "Invalid Password!", message: "Oops, password contains your name!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
        else {
            let alert = UIAlertController(title: "Invalid Password!", message: "Oops, password length should be between 8 and 15!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            present(alert, animated: true, completion: nil)
        }

        return false
    }

    //MARK: - Method to collapse encrypt password from key

    func encryptPass(_ password: String, key: String) -> String {

        let alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var encryptedPass = ""
        for char in password {
            let c = Character(char.uppercased())

            if let index = alphabets.firstIndex(of: c) {

                let newVal = key[index]
                if c == char {
                    encryptedPass += String(newVal)
                }
                else {
                    encryptedPass += String(newVal.lowercased())
                }
            }
            else {
                encryptedPass += String(char)
            }

        }
        return encryptedPass
    }

    //MARK: - Method to prepare for segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let lvc = segue.destination as? ListViewController {
            lvc.currentUser = phoneNumber ?? "9000000000"
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
