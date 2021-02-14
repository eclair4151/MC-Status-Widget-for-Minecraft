//
//  FAQViewController.swift
//  MC Status
//
//  Created by Tomer on 2/14/21.
//  Copyright © 2021 ShemeshApps. All rights reserved.
//

import UIKit

class FAQViewController: UIViewController {

    @IBOutlet weak var faqTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        faqTextView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.faqTextView.setContentOffset(.zero, animated: false)
            self.faqTextView.automaticallyAdjustsScrollIndicatorInsets = false
            
            self.faqTextView.textColor =  UIColor { tc in
                        switch tc.userInterfaceStyle {
                        case .dark:
                            return UIColor.white
                        default:
                            return UIColor.black
                        }
                    }
        }
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
