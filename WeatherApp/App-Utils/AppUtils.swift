//
//  AppUtils.swift
//  WeatherApp
//
//  Created by Chaithra T V on 17/02/20.
//  Copyright © 2020 Chaithra TV. All rights reserved.
//

import Foundation
import UIKit

/* Show Progress Indicator */
func showProgressIndicator(view:UIView){
    view.isUserInteractionEnabled = false
    let progressIndicator = ProgressIndicator(text: "Please wait..")
    progressIndicator.tag = PROGRESS_INDICATOR_VIEW_TAG
    view.addSubview(progressIndicator)
}

/* Hide progress Indicator */
func hideProgressIndicator(view:UIView){
    DispatchQueue.main.async {
        view.isUserInteractionEnabled = true

        if let viewWithTag = view.viewWithTag(PROGRESS_INDICATOR_VIEW_TAG) {
            viewWithTag.removeFromSuperview()
        }
    }
}
