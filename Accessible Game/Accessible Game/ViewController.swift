//
//  menuViewController.swift
//  Accessible Game
//
//  Created by Serena Buxton on 4/28/19.
//  Copyright © 2019 Serena Buxton. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    

    @IBOutlet weak var pauseButton: UIBarButtonItem!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var smileLabel: UILabel!
    @IBOutlet weak var trackingView: ARSCNView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var allEmojis = [Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji()]
    var tmpEmoji = Emoji()
    var currentEmojiIndex = 0
    let testEmojis = ["😀","😉","😘","😜","🤨","😏","😟","😠","😲","😬","😐"]
    
    var currentGame = 0
    var setUp = false
    var callibrationRoundComplete = false
    var pauseEmojiMatch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check to make sure AR face tracking is supported
        guard ARFaceTrackingConfiguration.isSupported else {
            // If face tracking isn't available throw error and exit
            fatalError("ARKit is not supported on this device")
        }
        
        // Request camera permission
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
            if (granted) {
                // If access is granted, setup the main view
                DispatchQueue.main.sync {
                    self.resetTracking()
                }
            } else {
                // If access is not granted, throw error and exit
                fatalError("This app needs Camera Access to function. You can grant access in Settings.")
            }
        }
        for _ in 0..<2{
            self.tmpEmoji.toungeOut.append(0.0)
            self.tmpEmoji.jawOpen.append(0.0)
            self.tmpEmoji.mouthSmileLeft.append(0.0)
            self.tmpEmoji.mouthSmileRight.append(0.0)
            self.tmpEmoji.mouthPucker.append(0.0)
            self.tmpEmoji.mouthPressLeft.append(0.0)
            self.tmpEmoji.mouthPressRight.append(0.0)
            self.tmpEmoji.mouthDimpleLeft.append(0.0)
            self.tmpEmoji.browDownLeft.append(0.0)
            self.tmpEmoji.browDownRight.append(0.0)
            self.tmpEmoji.browInnerUp.append(0.0)
            self.tmpEmoji.browOuterUpLeft.append(0.0)
            self.tmpEmoji.mouthFrownLeft.append(0.0)
            self.tmpEmoji.mouthFrownRight.append(0.0)
            self.tmpEmoji.eyeLookDownLeft.append(0.0)
            self.tmpEmoji.eyeLookDownRight.append(0.0)
            self.tmpEmoji.eyeLookOutLeft.append(0.0)
            self.tmpEmoji.eyeBlinkRight.append(0.0)
            self.tmpEmoji.eyeBlinkLeft.append(0.0)
            self.tmpEmoji.eyeLeftWide.append(0.0)
            self.tmpEmoji.mouthDimpleRight.append(0.0)
        }
        
        switch currentGame {
            //generate emoji
        case 0:
            self.pageLabel.text = "Emoji Match"
            self.instructionsLabel.text = "Make a face and the emoji will change to match your face. Press capture to pause on an emoji."
            self.pauseButton.title = ""
        case 1:
            self.pageLabel.text = "Simon Says"
            self.instructionsLabel.text = "If Simon says match your face to the face of the emoji. If Simon doesn't say then make it as different as possible"
            self.pauseButton.title = "Pause"
        default:
            self.pageLabel.text = "Callibration"
            self.instructionsLabel.text = "In order to callibrate the app please match your face to the face of the shown emoji and press capture."
            self.button.setTitle("Capture", for: .normal)
            self.pauseButton.title = "Reset"
            self.smileLabel.text = testEmojis[currentEmojiIndex]
        }
        
        
    }
    
    func resetTracking() {
        //guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        trackingView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        trackingView.delegate = self
    }
    

    @IBAction func buttonPressed(_ sender: Any) {
        switch currentGame {
        case 0:
            if pauseEmojiMatch{
                pauseEmojiMatch = false
                self.instructionsLabel.text = "Make a face and the emoji will change to match your face. Press capture to pause on an emoji."
            }
            else{
                pauseEmojiMatch = true
                self.instructionsLabel.text = "Make a face and the emoji will change to match your face. Press capture to return to changing emojis."
            }
        case 1: simonSays()
        default: inputValuesButtonPressed()
        }
    }
    
    @IBAction func pauseButtonPressed(_ sender: Any) {
        switch currentGame {
        //case 0: generateEmoji()
        //case 1: simonSays()
        default: resetCallibration()
        }
    }
    func generateEmoji(){
        var min: Float = 10000000.0
        var index = 0
        var currentNorm: Float = 0.00
        var i = 0
        
        for emoji in allEmojis{
            currentNorm = 0
            currentNorm += pow(emoji.toungeOut[0]/emoji.toungeOut[1] - tmpEmoji.toungeOut[0],2)
            var tmp2 = emoji.jawOpen[0]
            var tmp = emoji.jawOpen[0]/emoji.jawOpen[1] - tmpEmoji.jawOpen[0]
            currentNorm += pow(emoji.jawOpen[0]/emoji.jawOpen[1] - tmpEmoji.jawOpen[0],2)
            currentNorm += pow(emoji.mouthSmileLeft[0]/emoji.mouthSmileLeft[1] - tmpEmoji.mouthSmileLeft[0],2)
            currentNorm += pow(emoji.mouthSmileRight[0]/emoji.mouthSmileRight[1] - tmpEmoji.mouthSmileRight[0],2)
            currentNorm += pow(emoji.mouthPucker[0]/emoji.mouthPucker[1] - tmpEmoji.mouthPucker[0],2)
            currentNorm += pow(emoji.mouthPressLeft[0]/emoji.mouthPressLeft[1] - tmpEmoji.mouthPressLeft[0],2)
            currentNorm += pow(emoji.mouthPressRight[0]/emoji.mouthPressRight[1] - tmpEmoji.mouthPressRight[0],2)
            currentNorm += pow(emoji.mouthDimpleLeft[0]/emoji.mouthDimpleLeft[1] - tmpEmoji.mouthDimpleLeft[0],2)
            currentNorm += pow(emoji.browDownRight[0]/emoji.browDownRight[1] - tmpEmoji.browDownRight[0],2)
            currentNorm += pow(emoji.browInnerUp[0]/emoji.browInnerUp[1] - tmpEmoji.browInnerUp[0],2)
            currentNorm += pow(emoji.mouthFrownLeft[0]/emoji.mouthFrownLeft[1] - tmpEmoji.mouthFrownLeft[0],2)
            currentNorm += pow(emoji.mouthFrownRight[0]/emoji.mouthFrownRight[1] - tmpEmoji.mouthFrownRight[0],2)
            currentNorm += pow(emoji.eyeLookDownLeft[0]/emoji.eyeLookDownLeft[1] - tmpEmoji.eyeLookDownLeft[0],2)
            currentNorm += pow(emoji.eyeLookDownRight[0]/emoji.eyeLookDownRight[1] - tmpEmoji.eyeLookDownRight[0],2)
            currentNorm += pow(emoji.eyeLookOutLeft[0]/emoji.eyeLookOutLeft[1] - tmpEmoji.eyeLookOutLeft[0],2)
            currentNorm += pow(emoji.eyeBlinkRight[0]/emoji.eyeBlinkRight[1] - tmpEmoji.eyeBlinkRight[0],2)
            currentNorm += pow(emoji.eyeBlinkLeft[0]/emoji.eyeBlinkLeft[1] - tmpEmoji.eyeBlinkLeft[0],2)
            currentNorm += pow(emoji.eyeLeftWide[0]/emoji.eyeLeftWide[1] - tmpEmoji.eyeLeftWide[0],2)
            
            
            print(currentNorm)
            if currentNorm < min {
                min = currentNorm
                index = i
            }
            i+=1
        }
        smileLabel.text = testEmojis[index]
    }
    
    func simonSays(){
        
    }
    
    func resetCallibration(){
        currentEmojiIndex = 0
        smileLabel.text = testEmojis[0]
        for i in 0..<11 {
            for j in 0..<2{
                allEmojis[i].toungeOut[j] = (0.0)
                allEmojis[i].jawOpen[j] = (0.0)
                allEmojis[i].mouthSmileLeft[j] = (0.0)
                allEmojis[i].mouthSmileRight[j]=(0.0)
                allEmojis[i].mouthPucker[j]=(0.0)
                allEmojis[i].mouthPressLeft[j]=(0.0)
                allEmojis[i].mouthPressRight[j]=(0.0)
                allEmojis[i].mouthDimpleLeft[j]=(0.0)
                allEmojis[i].browDownLeft[j]=(0.0)
                allEmojis[i].browDownRight[j]=(0.0)
                allEmojis[i].browInnerUp[j]=(0.0)
                allEmojis[i].browOuterUpLeft[j]=(0.0)
                allEmojis[i].mouthFrownLeft[j]=(0.0)
                allEmojis[i].mouthFrownRight[j]=(0.0)
                allEmojis[i].eyeLookDownLeft[j]=(0.0)
                allEmojis[i].eyeLookDownRight[j]=(0.0)
                allEmojis[i].eyeLookOutLeft[j]=(0.0)
                allEmojis[i].eyeBlinkRight[j]=(0.0)
                allEmojis[i].eyeBlinkLeft[j]=0.0
                allEmojis[i].eyeLeftWide[j]=(0.0)
                allEmojis[i].mouthDimpleRight[j]=(0.0)
            }
        }
        setUp = false
    }
    
    func inputValuesButtonPressed(){
        if(callibrationRoundComplete){
            smileLabel.isHidden = false
            callibrationRoundComplete = false
            self.instructionsLabel.text = "In order to callibrate the app please match your face to the face of the shown emoji and press capture."
            return
    
        }
        allEmojis[currentEmojiIndex].toungeOut[0] = allEmojis[currentEmojiIndex].toungeOut[0] + tmpEmoji.toungeOut[0]
        allEmojis[currentEmojiIndex].jawOpen[0] = allEmojis[currentEmojiIndex].jawOpen[0] + tmpEmoji.jawOpen[0]
        allEmojis[currentEmojiIndex].mouthSmileLeft[0] = allEmojis[currentEmojiIndex].mouthSmileLeft[0] + tmpEmoji.mouthSmileLeft[0]
        allEmojis[currentEmojiIndex].mouthSmileRight[0] = allEmojis[currentEmojiIndex].mouthSmileRight[0] + tmpEmoji.mouthSmileRight[0]
        allEmojis[currentEmojiIndex].mouthPucker[0] = allEmojis[currentEmojiIndex].mouthPucker[0] + tmpEmoji.mouthPucker[0]
        allEmojis[currentEmojiIndex].mouthPressLeft[0] = allEmojis[currentEmojiIndex].mouthPressLeft[0] + tmpEmoji.mouthPressLeft[0]
        allEmojis[currentEmojiIndex].mouthPressRight[0] = allEmojis[currentEmojiIndex].mouthPressRight[0] + tmpEmoji.mouthPressRight[0]
        allEmojis[currentEmojiIndex].mouthDimpleLeft[0] = allEmojis[currentEmojiIndex].mouthDimpleLeft[0] + tmpEmoji.mouthDimpleLeft[0]
        allEmojis[currentEmojiIndex].browDownLeft[0] = allEmojis[currentEmojiIndex].browDownLeft[0] + tmpEmoji.browDownLeft[0]
        allEmojis[currentEmojiIndex].browDownRight[0] = allEmojis[currentEmojiIndex].browDownRight[0] + tmpEmoji.browDownRight[0]
        allEmojis[currentEmojiIndex].browInnerUp[0] = tmpEmoji.browInnerUp[0] + allEmojis[currentEmojiIndex].browInnerUp[0]
        allEmojis[currentEmojiIndex].browOuterUpLeft[0] = tmpEmoji.browOuterUpLeft[0] + allEmojis[currentEmojiIndex].browOuterUpLeft[0]
        allEmojis[currentEmojiIndex].mouthFrownLeft[0] = tmpEmoji.mouthFrownLeft[0] + allEmojis[currentEmojiIndex].mouthFrownLeft[0]
        allEmojis[currentEmojiIndex].mouthFrownRight[0] = tmpEmoji.mouthFrownRight[0] + allEmojis[currentEmojiIndex].mouthFrownRight[0]
        allEmojis[currentEmojiIndex].eyeLookDownLeft[0] = tmpEmoji.eyeLookDownLeft[0] + allEmojis[currentEmojiIndex].eyeLookDownLeft[0]
        allEmojis[currentEmojiIndex].eyeLookDownRight[0] = tmpEmoji.eyeLookDownRight[0] + allEmojis[currentEmojiIndex].eyeLookDownRight[0]
        allEmojis[currentEmojiIndex].eyeLookOutLeft[0] = tmpEmoji.eyeLookOutLeft[0] + allEmojis[currentEmojiIndex].eyeLookOutLeft[0]
        allEmojis[currentEmojiIndex].eyeBlinkLeft[0] = tmpEmoji.eyeBlinkLeft[0] + allEmojis[currentEmojiIndex].eyeBlinkLeft[0]
        allEmojis[currentEmojiIndex].eyeBlinkRight[0]=tmpEmoji.eyeLookDownRight[0]+allEmojis[currentEmojiIndex].eyeBlinkRight[0]
        allEmojis[currentEmojiIndex].eyeLeftWide[0] = tmpEmoji.eyeLeftWide[0] + allEmojis[currentEmojiIndex].eyeLeftWide[0]

        allEmojis[currentEmojiIndex].toungeOut[1]+=1.0
        allEmojis[currentEmojiIndex].jawOpen[1]+=1
        allEmojis[currentEmojiIndex].mouthSmileLeft[1]+=1
        allEmojis[currentEmojiIndex].mouthSmileRight[1]+=1
        allEmojis[currentEmojiIndex].mouthPucker[1]+=1
        allEmojis[currentEmojiIndex].mouthPressLeft[1]+=1
        allEmojis[currentEmojiIndex].mouthPressRight[1]+=1
        allEmojis[currentEmojiIndex].mouthDimpleLeft[1]+=1
        allEmojis[currentEmojiIndex].browDownLeft[1]+=1
        allEmojis[currentEmojiIndex].browDownRight[1]+=1
        allEmojis[currentEmojiIndex].browInnerUp[1]+=1
        allEmojis[currentEmojiIndex].browOuterUpLeft[1]+=1
        allEmojis[currentEmojiIndex].mouthFrownLeft[1]+=1
        allEmojis[currentEmojiIndex].mouthFrownRight[1]+=1
        allEmojis[currentEmojiIndex].eyeLookDownLeft[1]+=1
        allEmojis[currentEmojiIndex].eyeLookDownRight[1]+=1
        allEmojis[currentEmojiIndex].eyeLookOutLeft[1]+=1
        allEmojis[currentEmojiIndex].eyeBlinkLeft[1]+=1
        allEmojis[currentEmojiIndex].eyeBlinkRight[1]+=1
        allEmojis[currentEmojiIndex].eyeLeftWide[1]+=1
        
        if currentEmojiIndex == 10{
            setUp = true
            instructionsLabel.text = "Callibration complete! Callibration can be continued to ensure better results. To continue press 'calibrate'"
            smileLabel.isHidden = true
            callibrationRoundComplete = true
        }
        currentEmojiIndex = (currentEmojiIndex + 1)%11
        smileLabel.text = testEmojis[currentEmojiIndex]
    }
    
    
    
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Cast anchor as ARFaceAnchor
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        var bledShapes:[ARFaceAnchor.BlendShapeLocation:Any] = faceAnchor.blendShapes
        
        DispatchQueue.main.async {
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
            guard let mouthDimpleRight = bledShapes[.mouthDimpleRight] as? Float else {return}
            guard let browOuterUpLeft = bledShapes[.browOuterUpLeft] as? Float else {return}
            guard let eyeLeftWide = bledShapes[.eyeWideLeft] as? Float else {return}
            guard let mouthFrownLeft = bledShapes[.mouthFrownLeft] as? Float else {return}
            guard let mouthFrownRight = bledShapes[.mouthFrownRight] as? Float else{return}
            guard let eyeLookDownLeft = bledShapes[.eyeLookDownLeft] as? Float else{return}
            guard let eyeLookDownRight = bledShapes[.eyeLookDownRight] as? Float else{return}
            guard let eyeLookOutLeft = bledShapes[.eyeLookOutLeft] as? Float else{return}
            
            // Update label for new smile value
            self.tmpEmoji.toungeOut[0] = toungeOut
            self.tmpEmoji.jawOpen[0] = jawOpen
            self.tmpEmoji.mouthSmileLeft[0]=mouthSmileLeft
            self.tmpEmoji.mouthSmileRight[0]=mouthSmileRight
            self.tmpEmoji.mouthPucker[0]=mouthPucker
            self.tmpEmoji.mouthPressLeft[0]=mouthPressLeft
            self.tmpEmoji.mouthPressRight[0]=mouthPressRight
            self.tmpEmoji.mouthDimpleLeft[0]=mouthDimpleLeft
            self.tmpEmoji.mouthDimpleRight[0]=mouthDimpleLeft
            self.tmpEmoji.browDownLeft[0]=browDownLeft
            self.tmpEmoji.browDownRight[0]=browDownRight
            self.tmpEmoji.browInnerUp[0]=browInnerUp
            self.tmpEmoji.browOuterUpLeft[0]=browOuterUpLeft
            self.tmpEmoji.mouthFrownLeft[0]=(mouthFrownLeft)
            self.tmpEmoji.mouthFrownRight[0]=(mouthFrownRight)
            self.tmpEmoji.eyeLookDownLeft[0]=(eyeLookDownLeft)
            self.tmpEmoji.eyeLookDownRight[0]=(eyeLookDownRight)
            self.tmpEmoji.eyeLookOutLeft[0]=(eyeLookOutLeft)
            self.tmpEmoji.eyeBlinkRight[0] = rightEye
            self.tmpEmoji.eyeBlinkLeft[0] = leftEye
            self.tmpEmoji.eyeLeftWide[0] = eyeLeftWide
            
            if self.currentGame == 0 && !self.pauseEmojiMatch {
                self.generateEmoji()
            }
            
        }
    
    }
    
}

