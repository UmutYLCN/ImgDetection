//
//  ViewController.swift
//  ImgDetection
//
//  Created by umut yalçın on 9.10.2023.
//

import UIKit
import SnapKit
import SwiftUI
import CoreML
import Vision

class HomeVC: UIViewController ,UIImagePickerControllerDelegate ,UINavigationControllerDelegate{
    
    var chosenImage = CIImage()
    private var imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .cyan
        
        return imageView
    }()
    
    private var changeBtn : UIButton = {
       
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "plus"), for: .normal)
        btn.tintColor = .white
        btn.layer.cornerRadius = 35
        btn.backgroundColor = .black
        btn.addTarget(self, action: #selector(handleChangeBtn), for: .touchUpInside)
        return btn
    }()
    
    private var headinglbl : UILabel = {
        let lbl = UILabel()
        lbl.text = "Result"
        lbl.font = UIFont.systemFont(ofSize: 30,weight: .bold)
        return lbl
    }()
    
    private var resultLbl : UILabel = {
        let lbl = UILabel()
        lbl.text = "%25 mountain"
        lbl.font = UIFont.systemFont(ofSize: 20,weight: .semibold)
        return lbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configure()
    }
    
    func configure(){
        configureConstraints()
    }
    
    @objc
    func handleChangeBtn(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker,animated: true,completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
        
        if let ciImage = CIImage(image: imageView.image!){
            chosenImage = ciImage
        }
        
        recognizeImage(image: chosenImage)
    }
    
    
    func configureConstraints(){
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(700)
        }
        
        view.addSubview(changeBtn)
        changeBtn.snp.makeConstraints { make in
            make.width.equalTo(70)
            make.height.equalTo(70)
            make.trailing.equalTo(-30)
            make.bottom.equalTo(-30)
        }
        
        
        view.addSubview(headinglbl)
        headinglbl.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(30)
            make.leading.equalTo(10)
            make.top.equalTo(imageView.snp.bottom).offset(15)
        }
        
        view.addSubview(resultLbl)
        resultLbl.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(30)
            make.leading.equalTo(10)
            make.top.equalTo(headinglbl.snp.bottom).offset(15)
        }
    }
    
    func recognizeImage(image : CIImage){
        if let model = try? VNCoreMLModel(for: MobileNetV2().model){
            let request = VNCoreMLRequest(model: model) {(vnrequest,error) in
                if let results = vnrequest.results as? [VNClassificationObservation] {
                    if results.count > 0 {
                        let topResult = results.first
                        
                        DispatchQueue.main.async {
                            let confidenceLevel = (topResult?.confidence ?? 0) * 100
                            
                            let rounded = Int(confidenceLevel * 100) / 100
                            
                            self.resultLbl.text = "\(rounded)% \(topResult!.identifier)"
                        }
                    }
                }
                
            }
            
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try handler.perform([request])
                }catch{
                    print("error")
                }
            }
        }
        
        
    }
}


struct HomeVCRepresentable : UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> HomeVC {
        HomeVC()
    }
    
    func updateUIViewController(_ uiViewController: HomeVC, context: Context) {
        
    }
    
    typealias UIViewControllerType = HomeVC

}


struct HomeVC_Previews : PreviewProvider {
    static var previews: some View {
        HomeVCRepresentable()
    }
}
