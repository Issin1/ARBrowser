//
//  ViewController+AR.swift
//  ARBrowser
//
//  Created by CuiZihan on 2020/7/27.
//  Copyright © 2020 CuiZihan. All rights reserved.
//

import SceneKit
import ARKit
import Vision

extension ViewController: ARSCNViewDelegate {
    
     // MARK: - ARSCNViewDelegate
        
    /*
        // Override to create and configure nodes for anchors added to the view's session.
        func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
            let node = SCNNode()
         
            return node
        }
    */
        
        
    func session(_ session: ARSession, didFailWithError error: Error) {
    // Present an error message to the user
        print("error: \(error.localizedDescription)")
        self.sessionInfoLabel.text = error.localizedDescription
    }
        
    func sessionWasInterrupted(_ session: ARSession) {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
        print("session is interrupted")
        self.sessionInfoLabel.text = "Session 被中断了"
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfo(session.currentFrame!, camera.trackingState)
    }
    
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    // 在场景的Node被添加之后应该做的
        if let planeAnchor = anchor as? ARPlaneAnchor, node.childNodes.count<1{
            DispatchQueue.main.async {
                self.sessionInfoLabel.isHidden = true
                let url:URL = URL(string:"https://www.github.com")!
                self.webView.loadRequest(URLRequest(url: url))
            }
            let browserPlane = SCNPlane(width: 1.0, height: 0.75)
            browserPlane.firstMaterial?.diffuse.contents = webView
            browserPlane.firstMaterial?.isDoubleSided = true
                
            let browserPlaneNode = SCNNode(geometry: browserPlane)
            browserPlaneNode.simdPosition = SIMD3(planeAnchor.center.x, 0, planeAnchor.center.z-1.0)
            node.addChildNode(browserPlaneNode)
            sceneView.debugOptions = []
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
    // 在锚点被更新之后需要做的
    }
}

extension ViewController {
    func initAR() {
        
        sceneView.debugOptions = [.showFeaturePoints]
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func pauseAR() {
        self.sceneView.session.pause()
    }
    
    func updateSessionInfo(_ frame: ARFrame, _ state: ARCamera.TrackingState) {
        let message: String
        print("status")
        switch state {
        case .normal where frame.anchors.isEmpty:
            // 未检测到平面
            message = "移动设备来探测平面."
            
        case .normal:
            // 平面可见,跟踪正常,无需反馈
            message = ""
            
        case .notAvailable:
            message = "无法追踪."
            
        case .limited(.excessiveMotion):
            message = "追踪受限-请缓慢移动设备."
            
        case .limited(.insufficientFeatures):
            message = "追踪受限-将设备对准平面上的可见花纹区域,或改善光照条件."
            
        case .limited(.initializing):
            message = "初始化AR中."
            
        case .limited(.relocalizing):
            message = ""
        case .limited(_):
            message = ""
        }
        print(message)
        
        self.sessionInfoLabel.text = message
    }
}
