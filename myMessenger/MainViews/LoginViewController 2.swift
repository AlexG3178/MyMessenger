//
//  ViewController.swift
//  myMessenger
//
//  Created by alex on 07.04.2022.
//

import UIKit
import ProgressHUD

class LoginViewController: UIViewController {
    
    var isLogin: Bool = true
    
    //MARK: - Outlets
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordLabel: UILabel!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var repeatPasswordLine: UIView!
    @IBOutlet weak var forgotPasswordBtn: UIButton!
    @IBOutlet weak var resendEmailBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var signUpLabel: UILabel!
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUIFor(login: true)
        setupTextFieldDelegates()
        setupBackgroundTap()
    }
    
    //MARK: - Actions
    @IBAction func forgotPasswordBtnPress(_ sender: Any) {
        if isDataInputedFor(type: "password") {
            resetPassword()
        } else {
            ProgressHUD.showFailed("Email is required")
        }
    }
    
    @IBAction func resendEmailBtnPress(_ sender: Any) {
        if isDataInputedFor(type: "password") {
            resendVerificationEmail()
        } else {
            ProgressHUD.showFailed("Email is required")
        }
    }
    
    @IBAction func loginBtnPress(_ sender: Any) {
        if isDataInputedFor(type: isLogin ? "login" : "register") {
            isLogin ? loginUser() : registerUser()
        } else {
            ProgressHUD.showFailed("All fields are required")
        }
    }
    
    //MARK: - Setup
    @IBAction func signUpBtnPress(_ sender: UIButton) {
        updateUIFor(login: sender.titleLabel?.text == "Login")
        isLogin.toggle()
    }
    
    private func setupBackgroundTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func backgroundTap() {
        view.endEditing(false)
    }
    
    private func setupTextFieldDelegates() {
        emailTextField.addTarget(self, action: #selector(textFielDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFielDidChange(_:)), for: .editingChanged)
        repeatPasswordTextField.addTarget(self, action: #selector(textFielDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFielDidChange(_ textField: UITextField) {
        updatePlaceholderLabels(textField: textField)
    }
    
    private func updateUIFor(login: Bool) {
        loginBtn.setImage(UIImage(named: login ? "loginBtn" : "registerBtn"), for: .normal)
        signUpBtn.setTitle(login ? "SignUp" : "Login", for: .normal)
        signUpLabel.text = login ? "Don't have an account?" : "Have an account?"
        UIView.animate(withDuration: 0.5) {
            self.repeatPasswordLabel.isHidden = login
            self.repeatPasswordTextField.isHidden = login
            self.repeatPasswordLine.isHidden = login
        }
    }
    
    private func updatePlaceholderLabels(textField: UITextField) {
        switch textField {
        case emailTextField:
            emailLabel.text = emailTextField.hasText ? "Email" : ""
        case passwordTextField:
            passwordLabel.text = passwordTextField.hasText ? "Password" : ""
        case repeatPasswordTextField:
            repeatPasswordLabel.text = repeatPasswordTextField.hasText ? "RepeatPassword" : ""
        default:
            break
        }
    }
    
    private func isDataInputedFor(type: String) -> Bool {
        switch type {
        case "login":
            return emailTextField.text != "" && passwordTextField.text != ""
        case "registration":
            return emailTextField.text != "" && passwordTextField.text != "" && repeatPasswordTextField.text != ""
        default:
            return emailTextField.text != ""
        }
    }
    
    private func loginUser() {
        if let emailText = emailTextField.text, let passwordText = passwordTextField.text {
            FirebaseUserListener.shared.loginUserWith(email: emailText, password: passwordText) { (error, isEmailVerified) in
                if error == nil {
                    if isEmailVerified {
                        self.goToApp()
                    } else {
                        ProgressHUD.showError("Please verify email")
                        self.resendEmailBtn.isHidden = false
                    }
                } else {
                    ProgressHUD.showError(error?.localizedDescription)
                }
            }
        }
    }
    
    private func registerUser() {
        if passwordTextField.text == repeatPasswordTextField.text {
            if let emailText = emailTextField.text, let passwordText = passwordTextField.text {
                FirebaseUserListener.shared.registerUserWith(email: emailText, password: passwordText) { (error) in
                    if error == nil {
                        ProgressHUD.showSuccess("Verification email sent")
                        self.resendEmailBtn.isHidden = false
                    } else {
                        ProgressHUD.showError(error?.localizedDescription)
                    }
                }
            }
        } else {
            ProgressHUD.showError("password and confirm don't match")
        }
    }
    
    private func goToApp() {
        guard let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainView") as? UITabBarController else {
            return
        }
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil)
    }
    
    private func resetPassword() {
        if let emailText = emailTextField.text {
            FirebaseUserListener.shared.resetPasswordFor(email: emailText) { (error) in
                if error == nil {
                    ProgressHUD.showSuccess("Reset link sent to email")
                } else {
                    ProgressHUD.showFailed(error?.localizedDescription)
                }
            }
        }
    }
    
    private func resendVerificationEmail() {
        if let emailText = emailTextField.text {
            FirebaseUserListener.shared.resendVerificationEmail(email: emailText) { (error) in
                if error == nil {
                    ProgressHUD.showSuccess("New verification email sent")
                } else {
                    ProgressHUD.showFailed(error?.localizedDescription)
                }
            }
        }
    }
}

