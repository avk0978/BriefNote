//
//  DetailViewController.swift
//  Snote
//
//  Created by Andrey Kolpakov on 07.12.2017.
//  Copyright © 2017 Andrey Kolpakov. All rights reserved.
//

import UIKit

protocol SaveEditingDataToNotesListDelegate {
    func saveNote (_ note: Notes, _ index: Int)
}


class DetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var delegate: SaveEditingDataToNotesListDelegate?

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    var note: Notes!
    var indexSegue: Int!
    
    override var prefersStatusBarHidden: Bool { return true }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image = note.image { imageView.image = UIImage(data: image) }
        textField.text = note.name
        textView.text = note.text
        
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
        if let image = imageView.image { note.image = (UIImagePNGRepresentation(image) as Data?) }
        note.name = textField.text
        note.text = textView.text
        delegate?.saveNote(note, indexSegue)
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func hidenKeyboard(_ sender: UIBarButtonItem) {
        view.endEditing(true)
    }
    
    
    @IBAction func photoButton(_ sender: UIBarButtonItem) {
        self.chooseImagePickerAction(source: .camera)
    }
    
    
    @IBAction func galleryButton(_ sender: UIBarButtonItem) {
        self.chooseImagePickerAction(source: .photoLibrary)
    }
    
    
    @IBAction func exitButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func imageVCSegue(_ sender: UITapGestureRecognizer) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ImageVC") as! ImageViewController
        vc.image = imageView
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
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
