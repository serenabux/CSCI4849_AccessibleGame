//
//  FirstViewController.swift
//  Accessible Game
//
//  Created by Serena Buxton on 4/24/19.
//  Copyright © 2019 Serena Buxton. All rights reserved.
//

import UIKit
import ARKit
import AVFoundation

//shout out to https://guides.codepath.com/ios/Creating-a-Custom-Camera-View for the tutorial for setting up a camera preview

class FirstViewController: UIViewController, ARSessionDelegate {
    
    //instance variables for setting up camera preview
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    @IBOutlet weak var cameraView: UIView!
    
    
    let session = ARSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard ARFaceTrackingConfiguration.isSupported else{print("Iphone X required"); return}
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        session.delegate = self
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Setup your camera here...
        //setup session
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        //set up to use front camera
        guard let frontCamera =
            AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
            else {
                print("Unable to access front camera!")
                return
        }
        //prepare input
        //AVCaptureDeviceInput will serve as the "middle man" to attach the input device
        do {
            let input = try AVCaptureDeviceInput(device: frontCamera)
            //configure output
            stillImageOutput = AVCapturePhotoOutput()
            stillImageOutput = AVCapturePhotoOutput()
            //if no errors have occured attach the input and the output
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
        }
        catch let error  {
            print("Error Unable to initialize front camera:  \(error.localizedDescription)")
            return
        }
    }
    
    var currentFaceAnchor: ARFaceAnchor?
    var currentFrame: ARFrame?
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        self.currentFrame = frame
        //start session for camera preview on background thread
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            //Step 13
        }
        //Size the Preview Layer to fit the camera preview
        DispatchQueue.main.async {
            self.videoPreviewLayer.frame = self.cameraView.bounds
        }
    }
    
    func setupLivePreview() {
        //configure the live previes
        //Create an AVCaptureVideoPreviewLayer and associate it with our session.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        //Configure the Layer to resize while maintaining it's original aspect.
        videoPreviewLayer.videoGravity = .resizeAspect
        //Fix the orientation to portrait
        videoPreviewLayer.connection?.videoOrientation = .portrait
        //dd the preview layer as a sublayer of our previewView
        cameraView.layer.addSublayer(videoPreviewLayer)
    }
    
    
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.first as? ARFaceAnchor else { return }
        self.currentFaceAnchor = faceAnchor
        update(withFaceAnchor: faceAnchor)
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
    
    //clean up when the user leaves 
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    
}
