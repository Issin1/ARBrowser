//
//  ViewController.swift
//  ARBrowser
//
//  Created by CuiZihan on 2020/7/27.
//  Copyright © 2020 CuiZihan. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import WebKit
import Vision

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    
    var planeNode: SCNNode!
    let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: 640, height: 480))
    
    let coreMLQueue = DispatchQueue.init(label: "cn.edu.nju.nemoworks.ARBrowser")
    
    lazy var request: VNCoreMLRequest = {
        do {
            let handModel = example_5s0_hand_model()
            let model = try VNCoreMLModel(for:handModel.model)
            var request = VNCoreMLRequest(model: model, completionHandler: self.processObservations)
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to create VNCoreMLRequest")
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initAR()
        self.coreMLQueue.async {
            self.loopCoreML()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.pauseAR()
    }
}
