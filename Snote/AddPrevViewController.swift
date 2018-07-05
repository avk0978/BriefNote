//
//  AddPrevViewController.swift
//  Snote
//
//  Created by Andrey Kolpakov on 21.12.2017.
//  Copyright © 2017 Andrey Kolpakov. All rights reserved.
//

import UIKit

class AddPrevViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var itemNavBar: UINavigationItem!
    
//    override var prefersStatusBarHidden: Bool { return true }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemNavBar.title = NSLocalizedString("New note", comment: "New note")
        textField.placeholder = NSLocalizedString("Title of this note", comment: "Title of this note")
        // Ждем сообщения от клавиатуры (клавиатура появилась/скрылась)
        NotificationCenter.default.addObserver(self, selector: #selector(kbDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbDidHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    @objc func kbDidShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let kbFrameSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        bottomConstraint.constant = kbFrameSize.height
    }
    
    
    @objc func kbDidHide() {
        bottomConstraint.constant = 0
    }
    
    
    func chooseImagePickerAction (source: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            guard (textField.text != "")||(textView.text != "") else {
                let ac = UIAlertController(title: nil, message: NSLocalizedString("Empty notes don't save", comment: "Empty notes don't save"), preferredStyle: .alert)
                let ok = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel, handler: nil)
                ac.addAction(ok)
                present(ac, animated: true, completion: nil)
                return
            }
            
            let noteObject = Notes(context: context)
            
            noteObject.block = false
            noteObject.name = textField.text
            noteObject.text = textView.text
            noteObject.date = NSDate() as Date
            if let img = imageView.image {
                noteObject.image = UIImagePNGRepresentation(img) as Data?
            } else {
                let img = UIImage(named: "Photo.png")
                noteObject.image = (UIImagePNGRepresentation(img!) as Data?)
            }
            
            do {
                try context.save()
                navigationController?.popViewController(animated: true) //Вызываем View Controler находящийся в вершине стека (возвращаемся обратно)
            } catch let error as NSError {
                let ac = UIAlertController(title: nil, message: "It was not succeeded to save the data \(error), \(error.userInfo)", preferredStyle: .alert)
                let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
                ac.addAction(cancel)
                present(ac, animated: true, completion: nil)
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func photoButton(_ sender: UIBarButtonItem) {
        self.chooseImagePickerAction(source: .camera)
    }
    @IBAction func galleryButton(_ sender: UIBarButtonItem) {
        self.chooseImagePickerAction(source: .photoLibrary)
    }
    
    @IBAction func exitButton(_ sender: UIBarButtonItem) {
//        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
