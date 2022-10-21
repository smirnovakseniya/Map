//
//  InfoVC.swift
//  Map
//
//  Created by Kseniya Smirnova on 18.10.22.
//

import UIKit

protocol InfoVCDelegate: AnyObject {
    func update(text: Bool)
}

class InfoVC: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    //MARK: - Variables
    
    weak var delegate: InfoVCDelegate?
    var info: InfoPath?
    
    static func initialization(_ code: InfoPath, delegate: InfoVCDelegate) -> InfoVC {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "infoVC") as! InfoVC
        if let presentationController = controller.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium(), .large()]
        }
        controller.info = code
        controller.delegate = delegate
        return controller
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addInfo()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.update(text: false)
    }
    
    //MARK: - Functions

    func addInfo() {
        guard let info = info else { return }
        dateLabel.text = "Дата: \(String(describing: info.date))"
        nameLabel.text = "Рейс: \(String(describing: info.name))"
        infoLabel.text = info.info
    }
}
