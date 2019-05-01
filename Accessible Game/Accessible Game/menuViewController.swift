//
//  menuViewController.swift
//  Accessible Game
//
//  Created by Serena Buxton on 4/28/19.
//  Copyright © 2019 Serena Buxton. All rights reserved.
//

import UIKit

//manages menu
//changes mode
//manages data persistance
//passes data back and forth from other view controller
class menuViewController: UIViewController {
    
    @IBOutlet weak var menuImage: UIImageView!
    @IBOutlet weak var generateEmojiButton: UIButton!
    @IBOutlet weak var simonSaysButton: UIButton!
    @IBOutlet weak var callibrationButton: UIButton!
    @IBOutlet weak var setUpInstructions: UILabel!
    var allEmojis = [Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji(),Emoji()]
    var tmpEmoji = Emoji()
    var setUp = false
    var currentEmojiIndex = 0
    
    let filename = "emojiData.plist"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //application instance
        let app = UIApplication.shared
        //subscribe to the UIApplicationWillResignActiveNotificationnotification
        NotificationCenter.default.addObserver(self, selector:
            #selector(menuViewController.applicationWillResignActive(_:)), name:
            UIApplication.willResignActiveNotification, object: app)
        
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
        //url of data file
        let fileURL = dataFileURL(filename)
        //if the data file exists, use it
        if FileManager.default.fileExists(atPath: (fileURL?.path)!){
            let url = fileURL!
            do {
                //creates a data buffer with the contents of the plist
                let data = try Data(contentsOf: url)
                //create an instance of PropertyListDecoder
                let decoder = PropertyListDecoder()
                //decode the data using the structure of the emoji class
                allEmojis = try decoder.decode([Emoji].self, from: data)
                setUpInstructions.isHidden = true
                setUp = true
                simonSaysButton.isEnabled = true
                generateEmojiButton.isEnabled = true
                menuImage.isHidden = false
                for i in 0..<11 {
                    if allEmojis[i].toungeOut[0] == 0.0 && allEmojis[i].jawOpen[0] == 0.0 && allEmojis[i].mouthSmileLeft[0] == 0.0 {
                        setUp = false
                        simonSaysButton.isEnabled = false
                        generateEmojiButton.isEnabled = false
                        currentEmojiIndex = i
                        menuImage.isHidden = true
                        setUpInstructions.isHidden = false
                        break
                        
                    }
                }


            } catch {
                print("no file")
            }
        }
        else {
            print("file does not exist")
            for i in 0..<11 {
                for _ in 0..<2{
                    allEmojis[i].toungeOut.append(0.0)
                    allEmojis[i].jawOpen.append(0.0)
                    allEmojis[i].mouthSmileLeft.append(0.0)
                    allEmojis[i].mouthSmileRight.append(0.0)
                    allEmojis[i].mouthPucker.append(0.0)
                    allEmojis[i].mouthPressLeft.append(0.0)
                    allEmojis[i].mouthPressRight.append(0.0)
                    allEmojis[i].mouthDimpleLeft.append(0.0)
                    allEmojis[i].browDownLeft.append(0.0)
                    allEmojis[i].browDownRight.append(0.0)
                    allEmojis[i].browInnerUp.append(0.0)
                    allEmojis[i].browOuterUpLeft.append(0.0)
                    allEmojis[i].mouthFrownLeft.append(0.0)
                    allEmojis[i].mouthFrownRight.append(0.0)
                    allEmojis[i].eyeLookDownLeft.append(0.0)
                    allEmojis[i].eyeLookDownRight.append(0.0)
                    allEmojis[i].eyeLookOutLeft.append(0.0)
                    allEmojis[i].eyeBlinkRight.append(0.0)
                    allEmojis[i].eyeBlinkLeft.append(0.0)
                    allEmojis[i].eyeLeftWide.append(0.0)
                    allEmojis[i].mouthDimpleRight.append(0.0)
                }
            }
            simonSaysButton.isEnabled = false
            generateEmojiButton.isEnabled = false
            menuImage.isHidden = true
        }
        
        
      

        // Do any additional setup after loading the view.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let sceneViewController = segue.destination as! ViewController
        for i in 0..<11 {
            sceneViewController.allEmojis[i] = allEmojis[i]
        }
        sceneViewController.setUp = setUp
        sceneViewController.currentEmojiIndex = currentEmojiIndex
        if segue.identifier == "inputSegue"{
            sceneViewController.currentGame = 2        }
        else if segue.identifier == "generateSegue"{
            sceneViewController.currentGame = 0
        }
        else{
            sceneViewController.currentGame = 1
        }
    }

    
    @IBAction func unwindSegue(_ segue:UIStoryboardSegue){
        let sceneViewController = segue.source as! ViewController
        for i in 0..<11 {
            allEmojis[i] = sceneViewController.allEmojis[i]
        }
        setUp = sceneViewController.setUp
        currentEmojiIndex = sceneViewController.currentEmojiIndex
        if setUp {
            setUpInstructions.isHidden = true
            simonSaysButton.isEnabled = true
            generateEmojiButton.isEnabled = true
            menuImage.isHidden = false
        }
        else{
            setUpInstructions.isHidden = false
            simonSaysButton.isEnabled = false
            generateEmojiButton.isEnabled = false
            menuImage.isHidden = true
        }
    }
    
    func dataFileURL(_ filename:String) -> URL? {
        //returns an array of URLs for the document directory in the user's home directory
        let urls = FileManager.default.urls(for:.documentDirectory,
                                            in: .userDomainMask)
        var url : URL?
        //append the file name to the first item in the array which is the document directory
        url = urls.first?.appendingPathComponent(filename)
        //return the URL of the data file or nil if it does not exist
        return url
    }
    
    //called when the UIApplicationWillResignActiveNotification notificationis posted
    //all notification methods take a single NSNotification instance astheir argument
    @objc func applicationWillResignActive(_ notification: NSNotification){
        //url of data file
        let fileURL = dataFileURL(filename)
        //create an instance of PropertyListEncoder
        let encoder = PropertyListEncoder()
        //set format type to xml
        encoder.outputFormat = .xml
        do {
            //encode the data using the structure of the Favoriteclass
            let plistData = try encoder.encode(allEmojis)
            //write encoded data to the file
            try plistData.write(to: fileURL!)
        } catch {
            print("write error")
        }
    }

}
