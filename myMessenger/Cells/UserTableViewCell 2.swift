//
//  UserTableViewCell.swift
//  myMessenger
//
//  Created by alex on 13.04.2022.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configure(user: User) {
        usernameLbl.text = user.name
        setAvatar(avatarLink: user.avatarLink)
    }
    
    private func setAvatar(avatarLink: String) {
        if avatarLink != "" {
            FileStorage.downloadImage(imageUrl: avatarLink) { (avatarImg) in
                self.avatarImg.image = avatarImg?.circleMasked
            }
        } else {
            self.avatarImg.image = UIImage(named: "avatar")?.circleMasked
        }
    }
}
