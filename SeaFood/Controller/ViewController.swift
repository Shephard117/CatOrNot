//
//  ViewController.swift
//  SeaFood
//
//  Created by Дмитрий Скоробогаты on 06.09.2021.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}


extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            guard let ciimage = CIImage(image: userPickedImage) else { fatalError("Problem to convert CIImage") }
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: MLModel(contentsOf: Inceptionv3.urlOfModelInThisBundle)) else {fatalError("Somethig go wrong with model")}
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {fatalError("Faild to cast results") }
            if let firstResult = results.first {
                if firstResult.identifier.contains("cat") {
                    self.navigationItem.title = "This is a cat!"
                    self.navigationController?.navigationBar.backgroundColor = .green
                } else {
                    self.navigationItem.title = "This is'n a cat!"
                    self.navigationController?.navigationBar.backgroundColor = .red
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print("Handler error: \(error.localizedDescription)")
        }
    }
}
