//
//  ViewController+ML.swift
//  ARBrowser
//
//  Created by CuiZihan on 2020/7/27.
//  Copyright © 2020 CuiZihan. All rights reserved.
//

import Vision
import CoreML
import UIKit

extension ViewController {
    
    func updateCoreML() {
        let pixbuffer: CVPixelBuffer? = (self.sceneView.session.currentFrame?.capturedImage)
        if pixbuffer == nil {return}
        let ciImage = CIImage(cvPixelBuffer: pixbuffer!)
        
        let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        do {
            try imageRequestHandler.perform([self.request])
        } catch {
            print(error)
        }
    }
    
    func loopCoreML() {
        while true {
            updateCoreML()
        }
    }
    
    func processObservations(for request: VNRequest, error: Error?) {
        // print("\(request.results)")
        
        guard let observations = request.results else {
            return
        }

        let classifications = observations[0...2].compactMap({$0 as? VNClassificationObservation})
            .map({"\($0.identifier)"})
        
        DispatchQueue.main.async {
            let firstIdentifier = classifications[0]
            if firstIdentifier == "fist-UB-RHand" {
                // 检测到拳头：
                self.resultLabel.text = "检测到👊"
                var scrollHeight: CGFloat = self.webView.scrollView.contentSize.height - self.webView.scrollView.bounds.size.height
                if scrollHeight < 0.0 {
                    scrollHeight = 0.0
                }
                self.webView.scrollView.setContentOffset(CGPoint(x: 0.0, y: scrollHeight), animated: true)
            } else if firstIdentifier == "FIVE-UB-RHand" {
                // 检测到手：
                self.resultLabel.text = "检测到👋"
                self.webView.scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
                
            } else {
                self.resultLabel.text = "🈚️"
            }
        }
    }
    
}
