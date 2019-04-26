//
//  ViewController.swift
//  Accessible Game
//
//  Created by Serena Buxton on 4/16/19.
//  Copyright © 2019 Serena Buxton. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSessionDelegate {

   
    @IBOutlet weak var sceneView: SCNView!
    
    var allEmojis = [Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji()]
    var currentEmojiIndex = 0
    
    let session = ARSession()

    @IBAction func buttonPressed(_ sender: UIButton) {
        update(withFaceAnchor: self.currentFaceAnchor!)
    }
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
    
    var currentFaceAnchor: ARFaceAnchor?
    var currentFrame: ARFrame?
    
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
    
    func update(withFaceAnchor faceAnchor: ARFaceAnchor) {
        var bledShapes:[ARFaceAnchor.BlendShapeLocation:Any] = faceAnchor.blendShapes
        //try to cast because if can not then cannot read value of coefficent
        guard let browInnerUp = bledShapes[.browInnerUp] as? Float else {return}
        guard let rightEye = bledShapes[.eyeBlinkRight] as? Float else {return}
        guard let leftEye = bledShapes[.eyeBlinkLeft] as? Float else {return}
        guard let toungeOut = bledShapes[.tongueOut] as? Float else {return}
        guard let jawOpen = bledShapes[.jawOpen] as? Float else {return}
        guard let mouthSmileLeft = bledShapes[.mouthSmileLeft] as? Float else {return}
        guard let mouthSmileRight = bledShapes[.mouthSmileRight] as? Float else {return}
        guard let browDownLeft = bledShapes[.browDownLeft] as? Float else {return}
        guard let browDownRight = bledShapes[.browDownRight] as? Float else {return}
        guard let mouthPucker = bledShapes[.mouthPucker] as? Float else {return}
        guard let mouthPressLeft = bledShapes[.mouthPressLeft] as? Float else {return}
        guard let mouthPressRight = bledShapes[.mouthPressRight] as? Float else {return}
        guard let mouthDimpleLeft = bledShapes[.mouthDimpleLeft] as? Float else {return}
        guard let browOuterUpLeft = bledShapes[.browOuterUpLeft] as? Float else {return}
        guard let eyeLeftWide = bledShapes[.eyeWideLeft] as? Float else {return}
        guard let mouthFrownLeft = bledShapes[.mouthFrownLeft] as? Float else {return}
        guard let mouthFrownRight = bledShapes[.mouthFrownRight] as? Float else{return}
        guard let eyeLookDownLeft = bledShapes[.eyeLookDownLeft] as? Float else{return}
        guard let eyeLookDownRight = bledShapes[.eyeLookDownRight] as? Float else{return}
        guard let eyeLookOutLeft = bledShapes[.eyeLookOutLeft] as? Float else{return}
        
        
        print("mouth smile left: \(mouthSmileLeft)")
        print("mouth smile right: \(mouthSmileRight)")
        print("brow down: \(browDownLeft)")
        print("left eye: \(leftEye)")
        print("right eye: \(rightEye)")
        print("tounge out: \(toungeOut)")
        print("jaw open: \(jawOpen)")
        print("brow down left: \(browDownLeft)")
        print("mouth pucker: \(mouthPucker)")
        print("mouthPressLeft: \(mouthPressLeft)")
        print("mouthPressRight: \(mouthPressRight)")
        print("mouthDimpleLeft: \(mouthDimpleLeft)")
        print("brow outer up left: \(browOuterUpLeft)")
        print("brow down right: \(browDownRight)")
        print("eye left wide: \(eyeLeftWide)")
        print("mouth frown left: \(mouthFrownLeft)")
        print("mouth frown right: \(mouthFrownRight)")
        print("brow inner up:\(browInnerUp)")
        print("eye look down left:\(eyeLookDownLeft)")
        print("eye look down right: \(eyeLookDownRight)")
        print("eye look out left: \(eyeLookOutLeft)")
        

        allEmojis[currentEmojiIndex].toungeOut.append(toungeOut)
        allEmojis[currentEmojiIndex].jawOpen.append(jawOpen)
        allEmojis[currentEmojiIndex].mouthSmileLeft.append(mouthSmileLeft)
        allEmojis[currentEmojiIndex].mouthSmileRight.append(mouthSmileRight)
        allEmojis[currentEmojiIndex].mouthPucker.append(mouthPucker)
        allEmojis[currentEmojiIndex].mouthPressLeft.append(mouthPressLeft)
        allEmojis[currentEmojiIndex].mouthPressRight.append(mouthPressRight)
        allEmojis[currentEmojiIndex].mouthDimpleLeft.append(mouthDimpleLeft)
        allEmojis[currentEmojiIndex].browDownLeft.append(browDownLeft)
        allEmojis[currentEmojiIndex].browDownRight.append(browDownRight)
        allEmojis[currentEmojiIndex].browInnerUp.append(browInnerUp)
        allEmojis[currentEmojiIndex].browOuterUpLeft.append(browOuterUpLeft)
        allEmojis[currentEmojiIndex].mouthFrownLeft.append(mouthFrownLeft)
        allEmojis[currentEmojiIndex].mouthFrownRight.append(mouthFrownRight)
        allEmojis[currentEmojiIndex].eyeLookDownLeft.append(eyeLookDownLeft)
        allEmojis[currentEmojiIndex].eyeLookDownRight.append(eyeLookDownRight)
        allEmojis[currentEmojiIndex].eyeLookOutLeft.append(eyeLookOutLeft)
        
        
        
//        if rightEye > 0.8 { //actually corresponds to left eye
//            print("right eye:\(rightEye)")//Range tiny to 0.9 (very quick changes)
//        }
//        if leftEye > 0.8{ //actually corresponds to right eye
//            print("left eye:\(leftEye)")
//        }
        //print("left eye:\(leftEye)") //Range tiny to 0.9 (very quick changes), camera angle effects this greatly
        //print("brow inner Up:\(browInnerUp)")
        //print("tounge out:\(toungeOut)")//Range close to 0 to 0.999
        //print("jaw open:\(jawOpen)") // Range 0.04 to 0.87
        
        
        
        
    }


}

