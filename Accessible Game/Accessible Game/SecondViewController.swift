//
//  SecondViewController.swift
//  Accessible Game
//
//  Created by Serena Buxton on 4/24/19.
//  Copyright © 2019 Serena Buxton. All rights reserved.
//

import UIKit
import ARKit

class SecondViewController: UIViewController, ARSessionDelegate {
    
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var emojiImage: UIImageView!
    
    var allEmojis = [Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji()]
    var currentEmojiIndex = 0
    
    let session = ARSession()
    var currentFaceAnchor: ARFaceAnchor?
    var currentFrame: ARFrame?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.backgroundColor = .clear
        self.sceneView.scene = SCNScene()
        self.sceneView.rendersContinuously = true
        
        guard ARFaceTrackingConfiguration.isSupported else{print("Iphone X required"); return}
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        session.delegate = self
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        
        
    }
    
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        self.currentFrame = frame
        DispatchQueue.main.async {
            // need to call heart beat on main thread
            
        }
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.first as? ARFaceAnchor else { return }
        self.currentFaceAnchor = faceAnchor
        //update(withFaceAnchor: faceAnchor)
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        
    }
    
    
    @IBAction func capturePressed(_ sender: Any) {
        update(withFaceAnchor: self.currentFaceAnchor!)
    }
    
    func update(withFaceAnchor faceAnchor: ARFaceAnchor) {
        var bledShapes:[ARFaceAnchor.BlendShapeLocation:Any] = faceAnchor.blendShapes
        //try to cast because if can not then cannot read value of coefficent
        guard let eyeBlinkRight = bledShapes[.eyeBlinkRight] as? Float else {return}
        print(eyeBlinkRight)
        guard let eyeBlinkLeft = bledShapes[.eyeBlinkLeft] as? Float else {return}
        guard let toungeOut = bledShapes[.tongueOut] as? Float else {return}
        guard let jawOpen = bledShapes[.jawOpen] as? Float else {return}
        guard let mouthSmileLeft = bledShapes[.mouthSmileLeft] as? Float else {return}
        guard let mouthSmileRight = bledShapes[.mouthSmileRight] as? Float else {return}
        guard let mouthPucker = bledShapes[.mouthPucker] as? Float else {return}
        guard let mouthPressLeft = bledShapes[.mouthPressLeft] as? Float else {return}
        guard let mouthPressRight = bledShapes[.mouthPressRight] as? Float else {return}
        guard let mouthDimpleLeft = bledShapes[.mouthDimpleLeft] as? Float else {return}
        guard let mouthDimpleRight = bledShapes[.mouthDimpleRight] as? Float else {return}
        guard let browDownLeft = bledShapes[.browDownLeft] as? Float else {return}
        guard let browDownRight = bledShapes[.browDownRight] as? Float else {return}
        guard let browInnerUp = bledShapes[.browInnerUp] as? Float else {return}
        guard let browOuterUpLeft = bledShapes[.browOuterUpLeft] as? Float else {return}
        guard let browOuterUpRight = bledShapes[.browOuterUpRight] as? Float else {return}
        guard let eyeWideLeft = bledShapes[.eyeWideLeft] as? Float else {return}
        guard let mouthFrownLeft = bledShapes[.mouthFrownLeft] as? Float else {return}
        guard let mouthFrownRight = bledShapes[.mouthFrownRight] as? Float else{return}
        guard let eyeLookDownLeft = bledShapes[.eyeLookDownLeft] as? Float else{return}
        guard let eyeLookDownRight = bledShapes[.eyeLookDownRight] as? Float else{return}
        guard let eyeLookOutLeft = bledShapes[.eyeLookOutLeft] as? Float else{return}
        
        allEmojis[currentEmojiIndex].eyeBlinkRight.append(eyeBlinkRight)
        allEmojis[currentEmojiIndex].eyeBlinkLeft.append(eyeBlinkLeft)
        allEmojis[currentEmojiIndex].toungeOut.append(toungeOut)
        allEmojis[currentEmojiIndex].jawOpen.append(jawOpen)
        allEmojis[currentEmojiIndex].mouthSmileLeft.append(mouthSmileLeft)
        allEmojis[currentEmojiIndex].mouthSmileRight.append(mouthSmileRight)
        allEmojis[currentEmojiIndex].mouthPucker.append(mouthPucker)
        allEmojis[currentEmojiIndex].mouthPressLeft.append(mouthPressLeft)
        allEmojis[currentEmojiIndex].mouthPressRight.append(mouthPressRight)
        allEmojis[currentEmojiIndex].mouthDimpleLeft.append(mouthDimpleLeft)
        allEmojis[currentEmojiIndex].mouthDimpleRight.append(mouthDimpleRight)
        allEmojis[currentEmojiIndex].browDownLeft.append(browDownLeft)
        allEmojis[currentEmojiIndex].browDownRight.append(browDownRight)
        allEmojis[currentEmojiIndex].browInnerUp.append(browInnerUp)
        allEmojis[currentEmojiIndex].browOuterUpLeft.append(browOuterUpLeft)
        allEmojis[currentEmojiIndex].browOuterUpRight.append(browOuterUpRight)
        allEmojis[currentEmojiIndex].eyeLeftWide.append(eyeWideLeft)
        allEmojis[currentEmojiIndex].mouthFrownLeft.append(mouthFrownLeft)
        allEmojis[currentEmojiIndex].mouthFrownRight.append(mouthFrownRight)
        allEmojis[currentEmojiIndex].eyeLookDownLeft.append(eyeLookDownLeft)
        allEmojis[currentEmojiIndex].eyeLookDownRight.append(eyeLookDownRight)
        allEmojis[currentEmojiIndex].eyeLookOutLeft.append(eyeLookOutLeft)
        
    }
    

    
    

    
}
