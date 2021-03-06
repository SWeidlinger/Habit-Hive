//
//  SignUpViewController.swift
//  HabitHiveTestLogin
//  Created by Sebastian Weidlinger on 30.05.21.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        firstNameTextField.becomeFirstResponder()
        setUpElements()
    }
    
    func setUpElements(){
        
        //Hide error Label
        errorLabel.alpha = 0
    }
    
    //checks the fields and validate the data is correct.
    //If everything correct returns nil,
    //otherwise returns an error message
    func validateFields() -> String?{
        
        //check that all fields are filled returns error message if not filled
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all the fields"
        }
        if (passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) != confirmPasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)){
            print(passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines))
            return "Passwords don't match"
        }
        return nil
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        
        //validate fields
        let error = validateFields()
        
        if error != nil{
            showError(error!)
        }
        else{
            
            //create cleaned versions of the data
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            //create the user
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                
                //check for errors
                if error != nil {
                    // there was an error creating user
                    if (password.count < 6){
                        self.showError("Password too short!")
                    }
                    else{
                        self.showError("Error creating User")
                    }
                }
                else{
                    //User was created succesfully, now store the first name and last name
                    let db = Firestore.firestore()
                    
                    db.collection("users").document(result!.user.uid).setData(["firstName" :firstName, "lastName": lastName, "uid": result!.user.uid, "habitCounter": 0, "achievements": [String](), "finishedHabits": 0]) {(error) in
                        if error != nil{
                            //show error message
                            self.showError("Error saving user data")
                        }
                    }
                    UserDefaults.standard.set(3, forKey: "sectionColor")
                    //transition to home screen
                    self.transitionToHome()
                }
            }
            
        }
    }
    
    func showError(_ message:String){
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func transitionToHome(){
        
        let tabBarViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.tabBarController) as? TabBarViewController
        self.view.window?.rootViewController = tabBarViewController
        self.view.window?.makeKeyAndVisible()
    }
}
