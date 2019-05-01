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
    

    @IBOutlet weak var topRightButton: UIBarButtonItem!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var smileLabel: UILabel!
    @IBOutlet weak var trackingView: ARSCNView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var allEmojis = [Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji()]
    var tmpEmoji = Emoji()
    //track what emoji was the last added to calibration
    var currentEmojiIndex = 0
    let labelEmojis = ["😀","😉","😘","😜","🤨","😏","😟","😠","😲","😬","😐"]
    
    //track current mode and if calibration has been complete
    var currentGame = 0
    var setUp = false
    var callibrationRoundComplete = false
    
    //used to freeze in Emoji Match
    var freezeMode = false
    
    //Timer varibales for Simon Says
    var timer = Timer()
    var timerIsDone = true
    let roundTime: Float = 8
    var currentTime: Float = 7
    
    //Varibales to help run Simon Says
    var gameEmojiIndex = 0
    var passed = false
    var simonSaysBool = false
    var points = 0
    
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
        //set tmp Emoji to have 1 value of summed values and 1 input
        for _ in 0..<2{
            self.tmpEmoji.toungeOut.append(1.0)
            self.tmpEmoji.jawOpen.append(1.0)
            self.tmpEmoji.mouthSmileLeft.append(1.0)
            self.tmpEmoji.mouthSmileRight.append(1.0)
            self.tmpEmoji.mouthPucker.append(1.0)
            self.tmpEmoji.mouthPressLeft.append(1.0)
            self.tmpEmoji.mouthPressRight.append(1.0)
            self.tmpEmoji.mouthDimpleLeft.append(1.0)
            self.tmpEmoji.browDownLeft.append(1.0)
            self.tmpEmoji.browDownRight.append(1.0)
            self.tmpEmoji.browInnerUp.append(1.0)
            self.tmpEmoji.browOuterUpLeft.append(1.0)
            self.tmpEmoji.mouthFrownLeft.append(1.0)
            self.tmpEmoji.mouthFrownRight.append(1.0)
            self.tmpEmoji.eyeLookDownLeft.append(1.0)
            self.tmpEmoji.eyeLookDownRight.append(1.0)
            self.tmpEmoji.eyeLookOutLeft.append(1.0)
            self.tmpEmoji.eyeBlinkRight.append(1.0)
            self.tmpEmoji.eyeBlinkLeft.append(1.0)
            self.tmpEmoji.eyeLeftWide.append(1.0)
            self.tmpEmoji.mouthDimpleRight.append(1.0)
        }
         self.topRightButton.isEnabled = true
        //change layout for view controller based on selection
        switch currentGame {
            //generate emoji
        case 0:
            self.pageLabel.text = "EmojiMe"
            self.instructionsLabel.text = "Make a face and the emoji will change to match your face. Press capture to pause on an emoji."
            self.topRightButton.title = "Freeze"
            progressBar.isHidden = true
            button.isHidden = true
            self.button.setTitle("Capture", for: .normal)
        case 1:
            self.pageLabel.text = "Simon Says"
            self.instructionsLabel.text = "If Simon says match your face to the face of the emoji. If Simon doesn't say then make it as different as possible"
            self.progressBar.isHidden = true
            self.smileLabel.isHidden = true
            self.button.setTitle("Play", for: .normal)
            self.topRightButton.title = ""
        default:
            self.pageLabel.text = "Calibration"
            self.instructionsLabel.text = "In order to calibrate the app please match your face to the face of the shown emoji and press capture."
            self.button.setTitle("Capture", for: .normal)
            self.topRightButton.title = "Reset"
            self.smileLabel.text = labelEmojis[currentEmojiIndex]
            progressBar.isHidden = true
        }
        
        
    }
    
    func resetTracking() {
        //guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        trackingView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        trackingView.delegate = self
    }
    


//perform different actions when button is pressed based on mode
    @IBAction func buttonPressed(_ sender: Any) {
        switch currentGame {
        case 0:
            if freezeMode{
                generateEmoji()
            }
            
        case 1:
            smileLabel.isHidden = false
            button.isHidden = true
            currentTime = roundTime-3
            points = 0
            simonSays()
        default: inputValuesButtonPressed()
        }
    }
    
    //button in the top right corner is pressed, perform different actions based on button press and mode ]
    @IBAction func pauseButtonPressed(_ sender: Any) {
        switch currentGame {
        case 0:
            if freezeMode{
                freezeMode = false
                button.isHidden = true
                topRightButton.title = "Freeze"
                self.instructionsLabel.text = "Make a face and the emoji will change to match your face. Press freeze mode to switch modes."
            }
            else{
                freezeMode = true
                button.isHidden = false
                topRightButton.title = "Regular"
                self.instructionsLabel.text = "Make a face and press capture the emoji will update to match your face. Press 'Regular' to switch modes."
            }
        default: resetCallibration()
        }
    }
    
    //generates the emoji and updates label for EmojMe mode
    func generateEmoji(){
        let index = compareSimilarity()
        smileLabel.text = labelEmojis[index]
    }

    //Use distance formula to figure out which input corresponds closest to users face
    //Consider each element of allEmojis which corresponds to the emojis in the label emojis
    //For each emoji compare all values and consider them elements in a vector
    func compareSimilarity()->Int {
        var min: Float = 10000000.0
        var index = 0
        var currentNorm: Float = 0.00
        var i = 0
        
        for emoji in allEmojis{
            currentNorm = 0
            currentNorm += pow(emoji.toungeOut[0]/emoji.toungeOut[1] - tmpEmoji.toungeOut[0],2)
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
            
            if currentNorm < min {
                min = currentNorm
                index = i
            }
            i+=1
        }
        return index
    }
    
    //runs a timer for Simon Says
    func runTimer() {
        timerIsDone = false
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    //Called by run timer
    //Perform checks for similarity
    //If simon says user must hold the face of the emoji for the given time (that emoji must be the most similar)
    //If simon doesn't say the user must never be the most similar to the given emoji
    //A transition period of 2 seconds allows the user to change their face
    //If user passes Simon Says is called again and the game continues
    @objc func updateTimer() {
        if currentTime > roundTime - 3{
            currentTime -= 1
            return
        }
        if currentTime > 1{
            currentTime -= 1     //This will decrement(count down)the seconds.
            print("Current time in update: \(currentTime)")
            progressBar.progress = currentTime/(roundTime - 3)
            let index = compareSimilarity()
            print(index)
            if index == gameEmojiIndex{
                if(simonSaysBool){
                   passed = true
                }
                else{
                    timer.invalidate()
                    currentTime = 0
                    timerIsDone = true
                    progressBar.isHidden = true
                    instructionsLabel.isHidden = false
                    instructionsLabel.text = "You lose! Simon didn't say " + labelEmojis[gameEmojiIndex] + "! Points: " + String(points)
                    button.isHidden = false
                    button.setTitle("Play Again?", for: .normal)
                    self.timerIsDone = true
                    timer.invalidate()
                    return
                }
                
            }
        }
        else{
            if (simonSaysBool){
                timer.invalidate()
                timerIsDone = true
                currentTime = 0
                progressBar.isHidden = true
                instructionsLabel.isHidden = false
                if(passed){
                    points+=1
                    simonSays()
                }
                else{
                    instructionsLabel.text = "You lose! You didn't match " + labelEmojis[gameEmojiIndex] + "! Points: " + String(points)
                    button.isHidden = false
                    button.setTitle("Play Again?", for: .normal)
                    self.timerIsDone = true
                    smileLabel.isHidden = true
                }
                
               return
            }
            else{
                currentTime = 0
                timer.invalidate()
                instructionsLabel.isHidden = false
                progressBar.isHidden = true
                timerIsDone = true
                points += 1
                simonSays()
                return
            }
        }
        
    }
    
    
    //Manages set up for each round of Simon Says Game Play
    func simonSays(){
        passed = false
        simonSaysBool = Bool.random()
        if simonSaysBool{
            pageLabel.text = "Simon Says"
        }
        else{
            pageLabel.text = ""
        }
            currentTime = roundTime - 3
        print("Current time: \(currentTime)")
            progressBar.isHidden = false
            instructionsLabel.isHidden = true
            progressBar.progress = 100
            gameEmojiIndex = Int.random(in: 0 ... 10)
            smileLabel.text = labelEmojis[gameEmojiIndex]
            runTimer()
    }
    
    
    //Clear all previous callibration so that the user can start fresh
    func resetCallibration(){
        topRightButton.isEnabled = false
        currentEmojiIndex = 0
        smileLabel.text = labelEmojis[0]
        let reset: Float = 0.0
        for i in 0..<11 {
            for j in 0..<2{
                allEmojis[i].toungeOut[j] = reset
                allEmojis[i].jawOpen[j] = reset
                allEmojis[i].mouthSmileLeft[j] = reset
                allEmojis[i].mouthSmileRight[j]=reset
                allEmojis[i].mouthPucker[j]=reset
                allEmojis[i].mouthPressLeft[j]=reset
                allEmojis[i].mouthPressRight[j]=reset
                allEmojis[i].mouthDimpleLeft[j]=reset
                allEmojis[i].browDownLeft[j]=reset
                allEmojis[i].browDownRight[j]=reset
                allEmojis[i].browInnerUp[j]=reset
                allEmojis[i].browOuterUpLeft[j]=reset
                allEmojis[i].mouthFrownLeft[j]=reset
                allEmojis[i].mouthFrownRight[j]=reset
                allEmojis[i].eyeLookDownLeft[j]=reset
                allEmojis[i].eyeLookDownRight[j]=reset
                allEmojis[i].eyeLookOutLeft[j]=reset
                allEmojis[i].eyeBlinkRight[j]=reset
                allEmojis[i].eyeBlinkLeft[j]=reset
                allEmojis[i].eyeLeftWide[j]=reset
                allEmojis[i].mouthDimpleRight[j]=reset
            }
        }
        setUp = false
    }
    
    
    //Cycle through emojis and store values for their face upon capture
    //They are stored in an array of the class Emoji
    //Each element in emoji is made up of attributes
    //Each attribute contains 2 elements, one for running sum and one for total input
    //When cycle is complete alert user
    func inputValuesButtonPressed(){
        if(callibrationRoundComplete){
            smileLabel.isHidden = false
            callibrationRoundComplete = false
            self.instructionsLabel.text = "Please match your face to the face of the shown emoji and press capture. To discard all previous data and start calibration over press reset."
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
        var reset: Float = 1
        
        
        allEmojis[currentEmojiIndex].toungeOut[1] += reset
        allEmojis[currentEmojiIndex].jawOpen[1] += reset
        allEmojis[currentEmojiIndex].mouthSmileLeft[1] += reset
        allEmojis[currentEmojiIndex].mouthSmileRight[1] += reset
        allEmojis[currentEmojiIndex].mouthPucker[1] += reset
        allEmojis[currentEmojiIndex].mouthPressLeft[1] += reset
        allEmojis[currentEmojiIndex].mouthPressRight[1] += reset
        allEmojis[currentEmojiIndex].mouthDimpleLeft[1]+=reset
        allEmojis[currentEmojiIndex].browDownLeft[1]+=reset
        allEmojis[currentEmojiIndex].browDownRight[1]+=reset
        allEmojis[currentEmojiIndex].browInnerUp[1]+=reset
        allEmojis[currentEmojiIndex].browOuterUpLeft[1]+=reset
        allEmojis[currentEmojiIndex].mouthFrownLeft[1]+=reset
        allEmojis[currentEmojiIndex].mouthFrownRight[1]+=reset
        allEmojis[currentEmojiIndex].eyeLookDownLeft[1]+=reset
        allEmojis[currentEmojiIndex].eyeLookDownRight[1]+=reset
        allEmojis[currentEmojiIndex].eyeLookOutLeft[1]+=reset
        allEmojis[currentEmojiIndex].eyeBlinkLeft[1]+=reset
        allEmojis[currentEmojiIndex].eyeBlinkRight[1]+=reset
        allEmojis[currentEmojiIndex].eyeLeftWide[1]+=reset
        
        if currentEmojiIndex == 10{
            setUp = true
            instructionsLabel.text = "Calibration complete! Calibration can be continued to ensure better results. To continue press 'calibrate'"
            smileLabel.isHidden = true
            callibrationRoundComplete = true
        }
        currentEmojiIndex = (currentEmojiIndex + 1)%11
        smileLabel.text = labelEmojis[currentEmojiIndex]
    }
    
    
    
}

//used to get face values
//continusly gets values 
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
            self.tmpEmoji.mouthDimpleRight[0]=mouthDimpleRight
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
            
            if self.currentGame == 0 && !self.freezeMode {
                self.generateEmoji()
            }
            
        }
    
    }
    
}

