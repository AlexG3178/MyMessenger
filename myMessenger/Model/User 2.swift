//
//  User.swift
//  myMessenger
//
//  Created by alex on 09.04.2022.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct User: Codable, Equatable {
    var id: String = ""
    var name: String
    var email: String
    var pushId: String = ""
    var avatarLink: String = ""
    var status: String
    
    static var currentId: String {
        return Auth.auth().currentUser?.uid ?? "!!!!! CURRENT USER NOT EXIST"
    }
    
    static var currentUser: User? {
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.data(forKey: kCURRENTUSER) {
                let decoder = JSONDecoder()
                do {
                    let userObject = try decoder.decode(User.self, from: dictionary)
                    return userObject
                } catch {
                    print("ERROR DECODING USER FROM DEFAULTS")
                }
            }
        }
        return nil
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

func saveUserLocally(_ user: User) {
    
    let encoder = JSONEncoder()
    do {
        let data = try encoder.encode(user)
        UserDefaults.standard.set(data, forKey: kCURRENTUSER)
    } catch {
        print("Error saving user locally", error.localizedDescription)
    }
}

func createDummyUsers() {
    
    let names = ["Billy Bob", "Uncle Bens", "Big Foot"]
    var imageIndex = 1
    var userIndex = 1
    
    for i in 0..<3 {
        let id = UUID().uuidString
        let fileDirectory = "Avatars/" + "_\(id)" + ".jpeg"
        if let image = UIImage(named: "user\(imageIndex)") {
            FileStorage.uploadImage(image, directory: fileDirectory) { (avatarLink) in
                let user = User(id: id, name: names[i], email: "user\(userIndex)", pushId: "", avatarLink: avatarLink ?? "", status: "")
                FirebaseUserListener.shared.saveUserToFirestore(user)
            }
        }
        userIndex += 1
        imageIndex += 1
    }
}
