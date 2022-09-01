//
//  FirebaseUserListener.swift
//  myMessenger
//
//  Created by alex on 09.04.2022.
//

import Foundation
import Firebase

class FirebaseUserListener {
    static let shared = FirebaseUserListener()
    private init() {}
    
    //MARK: - Login / Logout
    func loginUserWith(email: String, password: String, completion: @escaping(
        _ error: Error?, _ isEmailVerified: Bool) -> Void) {
            Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
                if let authDataResult = authDataResult {
                    if error == nil && authDataResult.user.isEmailVerified {
                        FirebaseUserListener.shared.downloadUserFromFirebase(userId: authDataResult.user.uid, email: email)
                        completion(error, true)
                    } else {
                        print("!!!!! EMAIL IS NOT VERIFIED")
                        completion(error, false)
                    }
                }
            }
        }
    
    func logOutCurrentUser(completion: @escaping(_ error: Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            userDefaults.removeObject(forKey: kCURRENTUSER)
            userDefaults.synchronize()
            completion(nil)
        } catch let error as NSError {
            completion(error)
        }
    }
    
    //MARK: - Email
    func resendVerificationEmail(email: String, completion: @escaping(_ error: Error?) -> Void) {
        Auth.auth().currentUser?.reload(completion: { (error) in
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                completion(error)
            })
        })
    }
    
    func resetPasswordFor(email: String, completion: @escaping(_ error: Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            completion(error)
        }
    }
    
    func registerUserWith(email: String, password: String, completion: @escaping(
        _ error: Error?) -> Void) {
            Auth.auth().createUser(withEmail: email, password: password) {
                (authDataResult, error) in
                completion(error)
                if error == nil {
                    authDataResult?.user.sendEmailVerification { (error) in
                        print("auth email sent with error: ", error?.localizedDescription ?? "")
                    }
                    if authDataResult?.user != nil {
                        let user = User(id: authDataResult?.user.uid ?? "!!!!! UID is empty", name: email, email: email, pushId: "", avatarLink: "", status: "Hi there, I've start using messenger")
                        saveUserLocally(user)
                        self.saveUserToFirestore(user)
                    }
                }
            }
        }
    
    //MARK: - Save
    func saveUserToFirestore(_ user: User) {
        do {
            try FirebaseReference(.User).document(user.id).setData(from: user)
        } catch {
            print(error.localizedDescription, "adding user")
        }
    }
    
    //MARK: - Download
    func downloadUserFromFirebase(userId: String, email: String? = nil) {
        FirebaseReference(.User).document(userId).getDocument { (querySnapshot, error) in
            guard let document = querySnapshot else {
                print("!!!!! NO DOCUMENT FOR USER")
                return
            }
            let result = Result {
                try? document.data(as: User.self)
            }
            switch result {
            case .success(let userObject):
                if let user = userObject {
                    saveUserLocally(user)
                } else {
                    print("DOCUMENT DOES NOT EXIST")
                }
            case .failure(let error):
                print("!!!!! ERROR DECODING USER", error)
            }
        }
    }
    
    func downloadAllUsersFromFirebase(completion: @escaping (_ allUsers: [User]) -> Void) {
        
        var users: [User] = []
        FirebaseReference(.User).limit(to: 100).getDocuments { (querySnapshot, error) in
            guard let document = querySnapshot?.documents else {
                print("@@@@@ NO DOCUMENTS IN ALL USERS")
                return
            }
            let allUsers = document.compactMap { (queryDocumentSnapshot) -> User? in
                return try? queryDocumentSnapshot.data(as: User.self)
            }
            for user in allUsers {
                if User.currentId != user.id {
                    users.append(user)
                }
            }
            completion(users)
        }
    }
    
    func downloadUsersFromFirebase(withIds: [String], completion: @escaping (_ allUsers: [User]) -> Void) {
        var count = 0
        var usersArray: [User] = []
        for userId in withIds {
            FirebaseReference(.User).document(userId).getDocument { (querySnapshot, error) in
                guard let document = querySnapshot else {
                    print("@@@@@ NO DOCUMENTS IN ALL USERS")
                    return
                }
                if let user = try? document.data(as: User.self) {
                    usersArray.append(user)
                    count += 1
                    
                    if count == withIds.count {
                        completion(usersArray)
                    }
                }
            }
        }
    }
    
    //MARK: - Update
    func updateUserInFirebase(_ user: User) {
        
        do {
            let _ = try FirebaseReference(.User).document(user.id).setData(from: user)
        } catch {
            print(error.localizedDescription, "updating user...")
        }
    }
}
