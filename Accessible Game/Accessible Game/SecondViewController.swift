//
//  FirstViewController.swift
//  Accessible Game
//
//  Created by Serena Buxton on 4/27/19.
//  Copyright © 2019 Serena Buxton. All rights reserved.
//

import UIKit
import ARKit

class SecondViewController: UIViewController {
    
    @IBOutlet weak var sLabel: UILabel!
    @IBOutlet weak var tView: ARSCNView!
    //var allEmojis = [Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji()]
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
        
        
        // Request camera permission
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
            if (granted) {
                // If access is granted, setup the main view
                DispatchQueue.main.sync {
                    self.setupSmileTracker()
                }
            } else {
                // If access is not granted, throw error and exit
                fatalError("This app needs Camera Access to function. You can grant access in Settings.")
            }
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
            for i in 0..<11 {
                allEmojis.append(Emoji())
            }
        }
        
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
    
    
    @IBAction func captureButtonPressed(_ sender: Any) {
        allEmojis[currentEmojiIndex].toungeOut.append(tmpEmoji.toungeOut[0])
        allEmojis[currentEmojiIndex].jawOpen.append(tmpEmoji.jawOpen[0])
        allEmojis[currentEmojiIndex].mouthSmileLeft.append(tmpEmoji.mouthSmileLeft[0])
        allEmojis[currentEmojiIndex].mouthSmileRight.append(tmpEmoji.mouthSmileRight[0])
        allEmojis[currentEmojiIndex].mouthPucker.append(tmpEmoji.mouthPucker[0])
        allEmojis[currentEmojiIndex].mouthPressLeft.append(tmpEmoji.mouthPressLeft[0])
        allEmojis[currentEmojiIndex].mouthPressRight.append(tmpEmoji.mouthPressRight[0])
        allEmojis[currentEmojiIndex].mouthDimpleLeft.append(tmpEmoji.mouthDimpleLeft[0])
        allEmojis[currentEmojiIndex].browDownLeft.append(tmpEmoji.browDownLeft[0])
        allEmojis[currentEmojiIndex].browDownRight.append(tmpEmoji.browDownRight[0])
        allEmojis[currentEmojiIndex].browInnerUp.append(tmpEmoji.browInnerUp[0])
        allEmojis[currentEmojiIndex].browOuterUpLeft.append(tmpEmoji.browOuterUpLeft[0])
        allEmojis[currentEmojiIndex].mouthFrownLeft.append(tmpEmoji.mouthFrownLeft[0])
        allEmojis[currentEmojiIndex].mouthFrownRight.append(tmpEmoji.mouthFrownRight[0])
        allEmojis[currentEmojiIndex].eyeLookDownLeft.append(tmpEmoji.eyeLookDownLeft[0])
        allEmojis[currentEmojiIndex].eyeLookDownRight.append(tmpEmoji.eyeLookDownRight[0])
        allEmojis[currentEmojiIndex].eyeLookOutLeft.append(tmpEmoji.eyeLookOutLeft[0])
        allEmojis[currentEmojiIndex].eyeBlinkLeft.append(tmpEmoji.eyeBlinkLeft[0])
        allEmojis[currentEmojiIndex].eyeBlinkRight.append(tmpEmoji.eyeLookDownRight[0])
        allEmojis[currentEmojiIndex].eyeLeftWide.append(tmpEmoji.eyeLeftWide[0])
        
        currentEmojiIndex = (currentEmojiIndex + 1)%11
        sLabel.text = testEmojis[currentEmojiIndex]
        
    }
    
    
    func setupSmileTracker() {
        // Configure and start face tracking session
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        
        // Run ARSession and set delegate to self
        tView.session.run(configuration)
        tView.delegate = self
        
        // Add trackingView so that it will run
        view.addSubview(tView)
        
        // Add smileLabel to UI
        buildSmileLabel()
    }
    
    func buildSmileLabel() {
        sLabel.text = testEmojis[currentEmojiIndex]
        sLabel.font = UIFont.systemFont(ofSize: 150)
        
        
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

extension SecondViewController: ARSCNViewDelegate {
    
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
    
}
