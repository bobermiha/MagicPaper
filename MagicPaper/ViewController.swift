//
//  ViewController.swift
//  MagicPaper
//
//  Created by Михаил Бобров on 29.10.2022.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView! {
        didSet {
            sceneView.delegate = self
            //            sceneView.showsStatistics = true
        }
    }
    
    private var videoNode = SKVideoNode()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARImageTrackingConfiguration()
        
        if let trackedImages = ARReferenceImage.referenceImages(
            inGroupNamed: "NewspaperImages",
            bundle: Bundle.main)
        {
            configuration.trackingImages = trackedImages
            configuration.maximumNumberOfTrackedImages = 1
            print("Images successfully found")
        } else {
            print("Thre is no images or some error occured")
        }
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        guard let imageAnchor = anchor as? ARImageAnchor,
              let videoName = imageAnchor.referenceImage.name else { return nil}
        
        
        videoNode = SKVideoNode(fileNamed: "\(videoName).mp4")
        
        videoNode.play()
        
        let videoScene = SKScene(size: CGSize(width: 1280, height: 720))
        videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
        videoNode.yScale = -1.0
        videoScene.scaleMode = .aspectFit
        videoScene.addChild(videoNode)
    
        
        
        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
        plane.firstMaterial?.diffuse.contents = videoScene
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -.pi / 2
        
        node.addChildNode(planeNode)
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        if node.isHidden == true {
            if let imageAnchor = anchor as? ARImageAnchor {
                sceneView.session.remove(anchor: imageAnchor)
                videoNode.pause()
            }
        } else {
            videoNode.play()
        }
    }
}
