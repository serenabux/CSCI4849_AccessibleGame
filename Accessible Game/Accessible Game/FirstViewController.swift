//
//  FirstViewController.swift
//  Accessible Game
//
//  Created by Serena Buxton on 4/27/19.
//  Copyright © 2019 Serena Buxton. All rights reserved.
//

import UIKit
import ARKit

class FirstViewController: UIViewController {
    
    
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var tView: ARSCNView!

    var allEmojis = [Emoji]()
    var tmpEmoji = Emoji()
    var currentEmojiIndex = 0
    let testEmojis = ["😀","😉","😘","😜","🤨","😏","😟","😠","😲","😬","😐"]
    let filename = "data.plist"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Not supported on this device")
        }
        
        
       
        
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
        
        let loadEmojis = loadData()
        if !loadEmojis{
            for _ in 0..<11 {
                allEmojis.append(Emoji())
            }
        }
        
        emojiLabel.isHidden = true
        tView.isHidden = true
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Request camera permission

        // Request camera permission
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
            if (granted) {
                // If access is granted, setup the main view
                DispatchQueue.main.sync {
                    //self.setupSmileTracker()
                    self.resetTracking()
                }
            } else {
                // If access is not granted, throw error and exit
                fatalError("This app needs Camera Access to function. You can grant access in Settings.")
            }
        }
    }
    

    @IBAction func playGame(_ sender: Any) {
        instructionsLabel.isHidden = true
        playButton.isHidden = true
        emojiLabel.isHidden = false
        tView.isHidden = false
    }
    func getDataFile(datafile: String) -> URL {
        //get path for data file
        let dirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docDir = dirPath[0] //documents directory
        print(docDir)
        
        // URL for our plist
        return docDir.appendingPathComponent(datafile)
    }
    
    func loadData()->Bool{
        let pathURL:URL?
        
        // URL for our plist
        let dataFileURL = getDataFile(datafile: filename)
        print(dataFileURL)
        
        //if the data file exists, use it
        if FileManager.default.fileExists(atPath: dataFileURL.path){
            pathURL = dataFileURL
        }
        else {
            return false
        }
        
        //creates a property list decoder object
        let plistdecoder = PropertyListDecoder()
        do {
            let data = try Data(contentsOf: pathURL!)
            //decodes the property list
            allEmojis = try plistdecoder.decode([Emoji].self, from: data)
            return true
        } catch {
            // handle error
            print(error)
            return false
        }
    }
    
    
    
    
    func setupSmileTracker() {
        // Configure and start face tracking session
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        
        // Run ARSession and set delegate to self
        tView.session.run(configuration)
        tView.delegate = self
    
        
        
    }
    
    func resetTracking() {
        //guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        tView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        tView.delegate = self
    }
    
    
}

extension FirstViewController: ARSCNViewDelegate {
    
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
            self.tmpEmoji.mouthSmileRight[0]=(mouthSmileRight)
            self.tmpEmoji.mouthPucker[0]=(mouthPucker)
            self.tmpEmoji.mouthPressLeft[0]=(mouthPressLeft)
            self.tmpEmoji.mouthPressRight[0]=(mouthPressRight)
            self.tmpEmoji.mouthDimpleLeft[0]=(mouthDimpleLeft)
            self.tmpEmoji.mouthDimpleRight[0]=(mouthDimpleLeft)
            self.tmpEmoji.browDownLeft[0]=(browDownLeft)
            self.tmpEmoji.browDownRight[0]=(browDownRight)
            self.tmpEmoji.browInnerUp[0]=(browInnerUp)
            self.tmpEmoji.browOuterUpLeft[0]=(browOuterUpLeft)
            self.tmpEmoji.mouthFrownLeft[0]=(mouthFrownLeft)
            self.tmpEmoji.mouthFrownRight[0]=(mouthFrownRight)
            self.tmpEmoji.eyeLookDownLeft[0]=(eyeLookDownLeft)
            self.tmpEmoji.eyeLookDownRight[0]=(eyeLookDownRight)
            self.tmpEmoji.eyeLookOutLeft[0]=(eyeLookOutLeft)
            self.tmpEmoji.eyeBlinkRight[0] = rightEye
            self.tmpEmoji.eyeBlinkLeft[0] = leftEye
            self.tmpEmoji.eyeLeftWide[0] = eyeLeftWide
        }
    }
    
    func dataFileURL(_ filename:String) -> URL? {
        //returns an array of URLs for the document directory in theuser's home directory
        let urls = FileManager.default.urls(for:.documentDirectory,
                                            in: .userDomainMask)
        var url : URL?
        //append the file name to the first item in the array which is the document directory
        url = urls.first?.appendingPathComponent(filename)
        //return the URL of the data file or nil if it does not exist
        return url
    }
    
    func writeData(){
        // URL for our plist
        let dataFileURL = getDataFile(datafile: filename)
        print(dataFileURL)
        //creates a property list decoder object
        let plistencoder = PropertyListEncoder()
        plistencoder.outputFormat = .xml
        do {
            let data = try plistencoder.encode(allEmojis.self)
            try data.write(to: dataFileURL)
        } catch {
            // handle error
            print(error)
        }
    }
    
    //called when the UIApplicationWillResignActiveNotification notification is posted
    //all notification methods take a single NSNotification instance as their argument
    @objc func applicationWillResignActive(_ notification: NSNotification){
        writeData()
    }
    
}
