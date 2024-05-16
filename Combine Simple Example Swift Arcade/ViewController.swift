//
//  ViewController.swift
//  Combine Simple Example Swift Arcade
//
//  Created by Anh Dinh on 5/14/24.
//

import UIKit
import Combine

class ViewController: UIViewController {

    @IBOutlet weak var tncSwitch: UISwitch!
    @IBOutlet weak var privacySwitch: UISwitch!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    // Create publishers
    @Published private var acceptedTerm: Bool = false
    @Published private var acceptedPrivacy: Bool = false
    @Published private var name = ""
    
    // Combine publishers into 1 single stream - 1 big publisher
    // This var will publish a Bool and
    // Never gets error
    private var validToSubmit: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest3($acceptedTerm, $acceptedPrivacy, $name)
            .map { terms, privacy, name in
                // Theo thu tu: term tuong ung voi $acceptedTerm
                // privacy tuong ung voi $acceptedPrivacy
                // name tuong ung voi $name
                // return 1 bool de tuong ung voi value type ma publisher publish which is Bool
                return terms && privacy && !name.isEmpty
            }
            .eraseToAnyPublisher()
            // genericizes the logic in .map to AnyPublisher
    }

    // Create subscriber
    private var buttonSubscriber: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.delegate = self
        
        // Connect subscriber and publisher
        buttonSubscriber = validToSubmit
            .receive(on: RunLoop.main)
            .assign(to: \.isEnabled, on: submitButton)
    }
    
    
    @IBAction func didSwitchTnC(_ sender: Any) {
        acceptedTerm = (sender as AnyObject).isOn
    }
    
    @IBAction func didSwitchPrivacy(_ sender: Any) {
        acceptedPrivacy = (sender as AnyObject).isOn
    }
    
    // textField changes
    // This func doens't work
    // For the sake of this example,
    // Use textFieldShouldReturn
    @IBAction func nameChanged(_ sender: Any) {
        name = (sender as AnyObject).text
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // When hitting return,
        // get the textField.text and close keyboard
        name = textField.text ?? ""
        textField.resignFirstResponder()
        return true
    }
}
