//
//  SettingsController.swift
//  TinderClone
//
//  Created by YouSS on 4/15/19.
//  Copyright © 2019 YouSS. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import JGProgressHUD

class SettingsController: UITableViewController {
        
    // instance properties
    lazy var image1Button = createButton(selector: #selector(handleSelectPhoto))
    lazy var image2Button = createButton(selector: #selector(handleSelectPhoto))
    lazy var image3Button = createButton(selector: #selector(handleSelectPhoto))
    
    let titles = ["Name", "Profession", "Age", "Bio", "Seeking Age Range"]
    var user: User?
    
    @objc func handleSelectPhoto(button: UIButton) {
        print("Select photo with button:", button)
        let imagePicker = CustomImagePickerController()
        imagePicker.delegate = self
        imagePicker.imageButton = button
        present(imagePicker, animated: true)
    }
    
    func createButton(selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        return button
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItems()
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
        
        fetchUser()
    }
    
    lazy var header: UIView = {
        let header = UIView()
        header.addSubview(image1Button)
        let padding: CGFloat = 16
        image1Button.anchor(top: header.topAnchor, leading: header.leadingAnchor, bottom: header.bottomAnchor, trailing: nil, padding: .init(top: padding, left: padding, bottom: padding, right: 0))
        image1Button.widthAnchor.constraint(equalTo: header.widthAnchor, multiplier: 0.45).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [image2Button, image3Button])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = padding
        
        header.addSubview(stackView)
        stackView.anchor(top: header.topAnchor, leading: image1Button.trailingAnchor, bottom: header.bottomAnchor, trailing: header.trailingAnchor, padding: .init(top: padding, left: padding, bottom: padding, right: padding))
        return header
    }()
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == 0 ? header : nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 300 : 40
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count + 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? nil : titles[section - 1]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 5 {
            let ageRangeCell = AgeRangeCell(style: .default, reuseIdentifier: nil)
            ageRangeCell.minSlider.addTarget(self, action: #selector(handleMinAgeChange), for: .valueChanged)
            ageRangeCell.maxSlider.addTarget(self, action: #selector(handleMaxAgeChange), for: .valueChanged)
            // we need to set up the labels on our cell here
            ageRangeCell.minLabel.text = "Min \(user?.minSeekingAge ?? -1)"
            ageRangeCell.maxLabel.text = "Max \(user?.maxSeekingAge ?? -1)"
            ageRangeCell.minSlider.value = Float(user?.minSeekingAge ?? -1)
            ageRangeCell.maxSlider.value = Float(user?.maxSeekingAge ?? -1)
            return ageRangeCell
        }
        
        let cell = SettingsCell(style: .default, reuseIdentifier: nil)
        cell.textField.placeholder = "Enter \(titles[indexPath.section - 1])"
        switch indexPath.section {
        case 1:
            cell.textField.text = user?.name
            cell.textField.addTarget(self, action: #selector(handleNameChange), for: .editingChanged)
        case 2:
            cell.textField.text = user?.profession
            cell.textField.addTarget(self, action: #selector(handleProfessionChange), for: .editingChanged)
        case 3:
            if let age = user?.age {
                cell.textField.text = String(age)
            }
            cell.textField.addTarget(self, action: #selector(handleAgeChange), for: .editingChanged)
        default: break
        }
        return cell
    }
    
    fileprivate func fetchUser() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("Users").document(userId).getDocument(completion: { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let data = snapshot?.data() else { return }
            self.user = User(dictionary: data)
            self.tableView.reloadData()
            self.loadUserPhoto()
        })
    }
    
    fileprivate func loadUserPhoto() {
        if let imageUrl1 = user?.imageUrl1, let url = URL(string: imageUrl1) {
            SDWebImageManager.shared.loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image1Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        if let imageUrl = user?.imageUrl2, let url = URL(string: imageUrl) {
            SDWebImageManager.shared.loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image2Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        if let imageUrl = user?.imageUrl3, let url = URL(string: imageUrl) {
            SDWebImageManager.shared.loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image3Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
    }
    
    fileprivate func setupNavigationItems() {
        navigationItem.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave)),
            UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleCancel))
        ]
    }
    
    @objc fileprivate func handleNameChange(textField: UITextField) {
        self.user?.name = textField.text
    }
    
    @objc fileprivate func handleProfessionChange(textField: UITextField) {
        self.user?.profession = textField.text
    }
    
    @objc fileprivate func handleAgeChange(textField: UITextField) {
        self.user?.age = Int(textField.text ?? "")
    }
    
    @objc fileprivate func handleCancel() {
        dismiss(animated: true)
    }
    
    @objc fileprivate func handleSave() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let docData: [String: Any] = [
            "uid": uid,
            "name": user?.name ?? "",
            "imageUrl1": user?.imageUrl1 ?? "",
            "imageUrl2": user?.imageUrl2 ?? "",
            "imageUrl3": user?.imageUrl3 ?? "",
            "age": user?.age ?? -1,
            "profession": user?.profession ?? "",
            "minSeekingAge": user?.minSeekingAge ?? -1,
            "maxSeekingAge": user?.maxSeekingAge ?? -1
        ]
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Saving settings"
        hud.show(in: view)
        Firestore.firestore().collection("Users").document(uid).setData(docData) { (err) in
            hud.dismiss()
            if let err = err {
                print("Failed to save user settings:", err)
                return
            }
            
            print("Finished saving user info")
        }
    }
    
    @objc fileprivate func handleMinAgeChange(slider: UISlider) {
        //        print(slider.value)
        // I want to update the minLabel in my AgeRangeCell somehow...
        //        let indexPath = IndexPath(row: 0, section: 5)
        //        let ageRangeCell = tableView.cellForRow(at: indexPath) as! AgeRangeCell
        //        ageRangeCell.minLabel.text = "Min \(Int(slider.value))"
        //
        //        self.user?.minSeekingAge = Int(slider.value)
        evaluateMinMax()
    }
    
    @objc fileprivate func handleMaxAgeChange(slider: UISlider) {
        //        let indexPath = IndexPath(row: 0, section: 5)
        //        let ageRangeCell = tableView.cellForRow(at: indexPath) as! AgeRangeCell
        //        ageRangeCell.maxLabel.text = "Max \(Int(slider.value))"
        //        self.user?.maxSeekingAge = Int(slider.value)
        evaluateMinMax()
    }
    
    fileprivate func evaluateMinMax() {
        guard let ageRangeCell = tableView.cellForRow(at: [5, 0]) as? AgeRangeCell else { return }
        let minValue = Int(ageRangeCell.minSlider.value)
        var maxValue = Int(ageRangeCell.maxSlider.value)
        maxValue = max(minValue, maxValue)
        ageRangeCell.maxSlider.value = Float(maxValue)
        ageRangeCell.minLabel.text = "Min \(minValue)"
        ageRangeCell.maxLabel.text = "Max \(maxValue)"
        
        user?.minSeekingAge = minValue
        user?.maxSeekingAge = maxValue
    }
    
}


extension SettingsController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.originalImage] as? UIImage
        let imageButton = (picker as? CustomImagePickerController)?.imageButton
        
        imageButton?.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        dismiss(animated: true)
        
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        guard let uploadData = selectedImage?.jpegData(compressionQuality: 0.75) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Uploading image..."
        hud.show(in: view)
        ref.putData(uploadData, metadata: metadata) { (nil, err) in
            if let err = err {
                hud.dismiss()
                print("Failed to upload image to storage:", err)
                return
            }
            
            print("Finished uploading image")
            ref.downloadURL(completion: { (url, err) in
                
                hud.dismiss()
                
                if let err = err {
                    print("Failed to retrieve download URL:", err)
                    return
                }
                
                print("Finished getting download url:", url?.absoluteString ?? "")
                
                if imageButton == self.image1Button {
                    self.user?.imageUrl1 = url?.absoluteString
                } else if imageButton == self.image2Button {
                    self.user?.imageUrl2 = url?.absoluteString
                } else {
                    self.user?.imageUrl3 = url?.absoluteString
                }
            })
        }
    }
}
