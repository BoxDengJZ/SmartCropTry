//
//  ZLCustomCamera.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/11.
//
//  Copyright (c) 2020 Long Zhang <longitachi@163.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import AVFoundation
import CoreMotion
import SnapKit

public
class CusCamera: UIViewController, CAAnimationDelegate {

    struct Layout {
        static let bottomViewH: CGFloat = 150
        static let largeCircleRadius: CGFloat = 80
        static let largeCircleRecordScale: CGFloat = 1.2
        
        static let smallCircleRecordScale: CGFloat = 0.7
    }
    
    var defaultRatio: Double = 1280 / 720
    var defaultResolution = CGSize(width: 720, height: 1280)
    @objc public var takeDoneBlockX: ( (String) -> Void )?
    
    lazy var tipView = LinedTipView()
    
    var hideTipsTimer: Timer?
    
    lazy var bottomView = ButtomViewP()
    
    lazy var buttomFinalView = ButtomViewFinal()
    
    
    lazy var lightBtn: UIButton = {
        let neBtn = UIButton(type: .custom)
        neBtn.setImage(UIImage(named: "camera_light_X"), for: .normal)
        neBtn.isHidden = true
        return neBtn
    }()
    
    
    lazy var bg: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black
        v.isHidden = true
        return v
    }()
    
    
    lazy var takedImageView: UIImageView = {
        let taked = UIImageView()
        taked.isHidden = true
        taked.contentMode = .scaleAspectFit
        taked.isUserInteractionEnabled = true
        return taked
    }()
    
    var takedImage: UIImage?
    
    var orientation: AVCaptureVideoOrientation = .portrait
    
    let session = AVCaptureSession()
    
    var videoInput: AVCaptureDeviceInput?
    
    lazy var imageOutput = AVCapturePhotoOutput()
    
    lazy var movieFileOutput = AVCaptureMovieFileOutput()
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var cameraConfigureFinish = false
    
    var layoutOK = false
    
    var dragStart = false
    
    var restartRecordAfterSwitchCamera = false
    
    var cacheVideoOrientation: AVCaptureVideoOrientation = .portrait
    
    var recordUrls = [URL]()
    
    var angleX: CGFloat = 0
    
    
    lazy var cropView = SECropView()

    lazy var areaCapture: CGRect = {
        let bottomH = 127 + UI.std.bottomOffsetY
        let w = UI.std.width
        let h = UI.std.height - bottomH
        return AVMakeRect(aspectRatio: defaultResolution, insideRect: CGRect(origin: .zero, size: CGSize(width: w, height: h)))
    }()
    
    lazy var areaInner: CGRect = {
        let bottomH = 127 + UI.std.bottomOffsetY
        let zeroW = UI.std.width
        let zeroH = UI.std.height - bottomH
        let firstW = zeroW - 60
        let firstH = zeroH - 60
        return AVMakeRect(aspectRatio: defaultResolution, insideRect: CGRect(origin: CGPoint(x: 30, y: 30), size: CGSize(width: firstW, height: firstH)))
    }()
    
    lazy var areaInnerRotateLeft: CGRect = {
        let bottomH = 127 + UI.std.bottomOffsetY
        let zeroW = UI.std.width
        let zeroH = UI.std.height - bottomH
        let firstW = zeroW - 60
        let firstH = zeroH - 60
        return AVMakeRect(aspectRatio: defaultResolution.flip, insideRect: CGRect(origin: CGPoint(x: 30, y: 30), size: CGSize(width: firstW, height: firstH)))
    }()
    
    var backToFlag = true
    
    var buttomArea: CGRect{
        let bottomH = 127 + UI.std.bottomOffsetY
        let y = UI.std.height - bottomH
        return CGRect(x: 0, y: y, width: view.bounds.width, height: bottomH)
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        self.cleanTimer()
        if self.session.isRunning {
            self.session.stopRunning()
        }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    @objc public init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        //  view.layer.debug()
        eventsD()
        let condition = UIImagePickerController.isSourceTypeAvailable(.camera)
        guard condition else{
            return
        }
        setupCamera()
        setupUI()
        
        AVCaptureDevice.requestAccess(for: .video) { (videoGranted) in
            if videoGranted {
                if ZLPhotoConfiguration.default().allowRecordVideo {
                    AVCaptureDevice.requestAccess(for: .audio) { (audioGranted) in
                        if !audioGranted {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.showAlertAndDismissAfterDoneAction(message: "noMicrophoneAuthority")
                            }
                        }
                    }
                }
            }
            else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.showAlertAndDismissAfterDoneAction(message: "noCameraAuthority")
                })
            }
        }
        if ZLPhotoConfiguration.default().allowRecordVideo {
            try? AVAudioSession.sharedInstance().setCategory(.playAndRecord)
            try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            showAlertAndDismissAfterDoneAction(message: "cameraUnavailable")
        } else if !ZLPhotoConfiguration.default().allowTakePhoto, !ZLPhotoConfiguration.default().allowRecordVideo {
            #if DEBUG
            fatalError("参数配置错误")
            #else
            showAlertAndDismissAfterDoneAction(message: "相机参数配置错误")
            #endif
        } else if self.cameraConfigureFinish, backToFlag {
            self.showTipsLabel()
            self.session.startRunning()
            self.setFocusCusor(point: self.view.center)
        }
        backToFlag = false
    }
    
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        session.stopRunning()
    }
    
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !self.layoutOK else { return }
        self.layoutOK = true
        previewLayer?.frame = areaCapture
        cropView.frame = areaInner
        takedImageView.frame = areaInner
        
        tipView.frame = areaCapture
        bottomView.frame = buttomArea
        buttomFinalView.frame = buttomArea
    }
    
    
    func resetResultImageFrame(){
        cropView.refresh(frame: areaInner)
        cropView.isHidden = true
        takedImageView.frame = areaInner
    }
    
    
    func setupUI() {
        view.backgroundColor = .black
        view.layer.debug()
        view.addSubs([bg, takedImageView, tipView,
                      bottomView, buttomFinalView,
                      lightBtn, cropView])
        
        cropView.imageView = takedImageView
        bg.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }

        lightBtn.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(20)
            m.top.equalToSuperview().offset(UI.std.origineY + 10)
            m.size.equalTo(CGSize(width: 40, height: 40))
        }
    }
    
    
    
    func eventsD(){
        if ZLPhotoConfiguration.default().allowTakePhoto {
            let takePictureTap = UITapGestureRecognizer(target: self, action: #selector(takePictureColor))
            bottomView.largeCircleB.addGestureRecognizer(takePictureTap)
        }
        
        let focusCursorTap = UITapGestureRecognizer(target: self, action: #selector(adjustFocusPoint))
        focusCursorTap.delegate = self
        self.view.addGestureRecognizer(focusCursorTap)
        
        bottomView.dismissBtn.addTarget(self, action: #selector(dismissBtnClick), for: .touchUpInside)
        

        buttomFinalView.retakeBtn.addTarget(self, action: #selector(retakeBtnClick), for: .touchUpInside)
        
        buttomFinalView.doneBtn.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        buttomFinalView.rotateBtn.addTarget(self, action: #selector(rotateBtnClickX), for: .touchUpInside)

            
    }
    
    
    func toggleLight(){
        lightBtn.isSelected.toggle()
    }
    
    
    func setupCamera() {
        guard let backCamera = self.getCamera(position: .back) else { return }
        
        guard let input = try? AVCaptureDeviceInput(device: backCamera) else { return }
        // 相机画面输入流
        self.videoInput = input
        
        // 音频输入流
        var audioInput: AVCaptureDeviceInput?
        if ZLPhotoConfiguration.default().allowRecordVideo, let microphone = getMicrophone{
            audioInput = try? AVCaptureDeviceInput(device: microphone)
        }
        
        session.sessionPreset = .hd1280x720
        
        // 解决视频录制超过10s没有声音的bug
        self.movieFileOutput.movieFragmentInterval = .invalid
        
        // 将视频及音频输入流添加到session
        if let vi = self.videoInput, self.session.canAddInput(vi) {
            self.session.addInput(vi)
        }
        if let ai = audioInput, self.session.canAddInput(ai) {
            self.session.addInput(ai)
        }
        // 将输出流添加到session
        if self.session.canAddOutput(self.imageOutput) {
            self.session.addOutput(self.imageOutput)
        }
        if self.session.canAddOutput(self.movieFileOutput) {
            self.session.addOutput(self.movieFileOutput)
        }
        // 预览layer
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        self.previewLayer?.videoGravity = .resizeAspect
        self.view.layer.masksToBounds = true
        self.view.layer.insertSublayer(self.previewLayer!, at: 0)
        
        self.cameraConfigureFinish = true
    }
    
    func getCamera(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position).devices
        for device in devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    var getMicrophone: AVCaptureDevice? {
        AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInMicrophone], mediaType: .audio, position: .unspecified).devices.first
    }
    
    
    func showAlertAndDismissAfterDoneAction(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "done", style: .default) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        self.showDetailViewController(alert, sender: nil)
    }
    
    func showTipsLabel(){
        tipView.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.25) {
            self.tipView.alpha = 1
        }
    }
    
    func hideTipsLabel(){
        self.cleanTimer()
        self.tipView.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.25) {
            self.tipView.alpha = 0
        }
    }
    
    func startHideTipsLabelTimer() {
        self.cleanTimer()
        self.hideTipsTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (timer) in
            self.hideTipsLabel()
        })
    }
    
    func cleanTimer() {
        self.hideTipsTimer?.invalidate()
        self.hideTipsTimer = nil
    }
    
    @objc func appWillResignActive() {
        if self.session.isRunning {
            self.dismiss(animated: true, completion: nil)
        }
    }
    

    
    @objc
    func dismissBtnClick(){
        gg()
    }
    
    
    
    func gg(){
        dismiss(animated: true, completion: nil)
    }
    

    
    
    
    @objc
    func retakeBtnClick(){
        angleX = 0
        takedImageView.transform = .identity
        
        session.startRunning()
        resetSubViewStatus()
        takedImage = nil
        resetResultImageFrame()
    }
    

    
    @objc
    func doneBtnClick(){
        
        guard cropView.isPathValid else{
            print("请重新选择区域")
            return
        }
        do {
            let idx = Int(angleX)
            guard let corners = cropView.cornerLocations, let img = takedImage?.image(rotated: idx) else { return }
            var b = takedImageView.bounds
            if idx % 2 != 0{
                let s = b.size.flip
                b.size = s
            }
            let croppedImage = try SEQuadrangleHelper.cropImage(in: b, with: img, quad: corners)
            var final = croppedImage
            let k = (idx % 4 + 4) % 4
            switch k {
            case 1:
                final = croppedImage.left
            case 2:
                final = croppedImage.down
            case 3:
                final = croppedImage.right
            default:
                ()
            }
            takedImageView.image = final
            // doReq(x: croppedImage)
        } catch let error as SECropError {
            print(error)
        } catch {
            print("Something went wrong, are you feeling OK?")
        }
    }
    
    @objc
    func rotateBtnClickX(){
        angleX -= 1
        takedImageView.transform = CGAffineTransform(rotationAngle: ImgSingleAngle.time * angleX)
        
        let idx = Int(angleX)
      //  takedImageView.image = takedImage?.image(rotated: idx)
        var inS = areaInner
        if idx % 2 != 0{
            inS = areaInnerRotateLeft
        }
        takedImageView.frame = inS
        cropView.refresh(frame: inS)
    }
    
    
    
    // 点击拍照
    @objc func takePictureColor(){
        let connection = self.imageOutput.connection(with: .video)
        connection?.videoOrientation = self.orientation
        if self.videoInput?.device.position == .front, connection?.isVideoMirroringSupported == true {
            connection?.isVideoMirrored = true
        }
        let setting = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        if let input = self.videoInput, input.device.isFlashAvailable{
            if lightBtn.isSelected{
                setting.flashMode = .on
            }
            else{
                setting.flashMode = .off
            }
        }
        imageOutput.capturePhoto(with: setting, delegate: self)
        
    }
    

    
    // 调整焦点
    @objc func adjustFocusPoint(_ tap: UITapGestureRecognizer) {
        guard self.session.isRunning else {
            return
        }
        let point = tap.location(in: self.view)
        if point.y > self.bottomView.frame.minY - 30 {
            return
        }
        self.setFocusCusor(point: point)
    }
    
    func setFocusCusor(point: CGPoint) {
        
        // ui坐标转换为摄像头坐标
        let cameraPoint = self.previewLayer?.captureDevicePointConverted(fromLayerPoint: point) ?? self.view.center
        self.focusCamera(mode: .autoFocus, exposureMode: .autoExpose, point: cameraPoint)
    }
    

    
    func setVideoZoomFactor(_ zoomFactor: CGFloat) {
        guard let device = self.videoInput?.device else {
            return
        }
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = zoomFactor
            device.unlockForConfiguration()
        } catch {
            zl_debugPrint("调整焦距失败 \(error.localizedDescription)")
        }
    }
    
    
    func focusCamera(mode: AVCaptureDevice.FocusMode, exposureMode: AVCaptureDevice.ExposureMode, point: CGPoint) {
        do {
            guard let device = self.videoInput?.device else {
                return
            }
            
            try device.lockForConfiguration()
            
            if device.isFocusModeSupported(mode) {
                device.focusMode = mode
            }
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = point
            }
            if device.isExposureModeSupported(exposureMode) {
                device.exposureMode = exposureMode
            }
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = point
            }
            
            device.unlockForConfiguration()
        } catch {
            zl_debugPrint("相机聚焦设置失败 \(error.localizedDescription)")
        }
    }
    

    func resetSubViewStatus(){
        let views: [UIView] = [buttomFinalView, bg]
        
        if session.isRunning {
            showTipsLabel()
            bottomView.isHidden = false
            views.forEach { $0.isHidden = true }
            takedImageView.isHidden = true
            takedImage = nil
        }
        else {
            hideTipsLabel()
            bottomView.isHidden = true
            views.forEach { $0.isHidden = false }
        }
    }
    

}


extension CusCamera: AVCapturePhotoCaptureDelegate {
    
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil {
            zl_debugPrint("拍照失败 \(error?.localizedDescription ?? "")")
            return
        }
        
        if let imgData = photo.fileDataRepresentation(){
            self.session.stopRunning()
            picTaken(img: imgData)
        }
    }

}
    
extension CusCamera{
    func picTaken(img imgData: Data){
        if let pic = UIImage(data: imgData){
            if pic.imageOrientation == .right{
                takedImage = pic.up.image(rotated: 1)
            }
            else{
                takedImage = pic
            }
        }
        picCommon()
    }
    
    
    func picAlbum(img pic: UIImage){
        takedImage = pic
        picCommon()
    }
    
    
    func picCommon(){
        takedImageView.image = takedImage
        takedImageView.isHidden = false
        resetSubViewStatus()
      
        cropView.configure(corners: takedImageView)
    }
    
}



extension CusCamera: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer, touch.view is UIControl {
            // 解决拖动改变焦距时，无法点击其他按钮的问题
            return false
        }
        return true
    }
    
}




struct ImgSingleAngle {
    static let time = CGFloat.pi * 0.5
}


extension CGSize{
    var flip: CGSize{
        CGSize(width: height, height: width)
    }
}
