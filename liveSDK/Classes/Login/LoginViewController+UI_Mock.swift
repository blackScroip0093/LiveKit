//
//  LoginViewController+UI.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 12/16/19.
//  Copyright © 2019 xcoderliu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Material
import Toast_Swift
import MJExtension


extension LoginViewController {
    
    /// 绘制UI
    func setupUI() {
        
        ToastManager.shared.position = .center
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .appBackGround
        
        view.addSubview(loading)
        loading.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.centerX.centerY.equalTo(view)
        }
        
        view.addSubview(trtcTitle)
        trtcTitle.snp.makeConstraints { (make) in
            make.leading.equalTo(32)
            make.top.equalTo(100)
            make.trailing.equalTo(-32)
            make.height.equalTo(30)
        }
        
        view.addSubview(phoneTip)
        phoneTip.snp.makeConstraints { (make) in
            make.leading.equalTo(32)
            make.top.equalTo(trtcTitle.snp.bottom).offset(60)
            make.trailing.equalTo(-32)
            make.height.equalTo(30)
        }
        
        func joinRoom(){

                        ProfileManager.shared.login(success: {
                            if ProfileManager.shared.curUserModel?.name.count == 0 {
            //                    self.showProfileVC()
                            } else {
                                self.loading.stopAnimating()
                                self.view.makeToast("登录成功")
                                
                                let room = TRTCLiveRoomInfo(roomId: phoneNumber.text ?? "", roomName: "", coverUrl: "", ownerId: "", ownerName: "", streamUrl: "", memberCount: 1, roomStatus: TRTCLiveRoomLiveStatus(rawValue: 0)!)
                                let tempVC = TCAudienceViewController(play: room, videoIsReady: {

                                })
                                tempVC?.needDict = self.resultNext
                                let liveRoom = TRTCLiveRoom()
                                
                                
                                
                                let userID = ProfileManager.shared.curUserID()
                                ProfileManager.shared.roomID = phoneNumber.text ?? ""
                                ProfileManager.shared.roomPassWord = passwordTextField.text ?? ""
                                ProfileManager.shared.roomNickName = nameTextField.text ?? ""
                                
                                let userSig = ProfileManager.shared.curUserSig()
                                let config = TRTCLiveRoomConfig()
                                if UserDefaults.standard.object(forKey: "liveRoomConfig_useCDNFirst") != nil {
                                    config.useCDNFirst = (UserDefaults.standard.object(forKey: "liveRoomConfig_useCDNFirst") as? NSNumber)?.boolValue ?? false
                                }
                                if config.useCDNFirst && UserDefaults.standard.object(forKey: "liveRoomConfig_cndPlayDomain") != nil {
                                    config.cdnPlayDomain = UserDefaults.standard.object(forKey: "liveRoomConfig_cndPlayDomain") as! String
                                }
                                liveRoom.login(sdkAppID: SDKAPPID, userID: userID ?? "", userSig: userSig, config: config, callback: { code, error in
                                                    let userID = ProfileManager.shared.curUserID()
                                                    let userSig = ProfileManager.shared.curUserSig()
                                                    TRTCCalling.shareInstance().imBusinessID = 1213214
                                                    TRTCCalling.shareInstance().deviceToken =  Data()
                                                    ProfileManager.shared.IMLogin(userSig: userSig, success: {
                                                        TRTCCalling.shareInstance().login(sdkAppID: UInt32(SDKAPPID), user: userID ?? "", userSig:
                                                            userSig, success: {
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                                //show main vc
                                                                liveRoom.setSelfProfile(name: ProfileManager.shared.roomNickName, avatarURL: "") { (tempInt, tempStr) in
                                                                    
                                                                }
                                                                tempVC?.liveRoom = liveRoom
                                                                
                                                                
                                                                self.navigationController?.pushViewController(tempVC!, animated: true)
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                                
                                                            }
                                                        }) { (Int32, String) in
                                    
                                                        }
                                                    }) { (error) in
                                    
                                                    }
                                })
                                
            //                    liveRoom.setSelfProfile(name: nameTextField.text ?? "1213", avatarURL: nil) { (tempInt, tempStr) in
            //                    //
            //                                        }
                                
            //                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            //                        //show main vc
            //
            //
            //                        AppUtils.shared.showMainController()
            //                    }
                            }
                        }, failed: { err in
                            self.loading.stopAnimating()
                            self.view.makeToast(err)
                        })
        }
        
        
        //UserID
        let (phoneNumber, numberSignal) = getTextObservable(placeholder: "请输入教室ID")
        phoneNumber.keyboardType = .numberPad
        phoneNumber.delegate = self
        view.addSubview(phoneNumber)
        phoneNumber.snp.makeConstraints { (make) in
            make.top.equalTo(phoneTip.snp.bottom).offset(2)
            make.leading.equalTo(32)
            make.trailing.equalTo(-32)
            make.height.equalTo(34)
        }
        
        numberSignal.subscribe(onNext: { (text) in
            print("phoneNumber:\(String(describing: text))")
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        numberSignal.bind(to: ProfileManager.shared.phone).disposed(by: disposeBag)
        
        view.addSubview(nameTip)
        nameTip.snp.makeConstraints { (make) in
            make.leading.equalTo(32)
            make.top.equalTo(phoneNumber.snp.bottom).offset(10)
            make.trailing.equalTo(-32)
            make.height.equalTo(30)
        }
        
        //昵称
        let (nameTextField, nameSignal) = getTextObservable(placeholder: "请输入昵称")
        nameTextField.delegate = self
        view.addSubview(nameTextField)
        nameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(nameTip.snp.bottom).offset(2)
            make.leading.equalTo(32)
            make.trailing.equalTo(-32)
            make.height.equalTo(34)
        }
        
        
        
        view.addSubview(passwordTip)
        passwordTip.snp.makeConstraints { (make) in
            make.leading.equalTo(32)
            make.top.equalTo(nameTextField.snp.bottom).offset(10)
            make.trailing.equalTo(-32)
            make.height.equalTo(30)
        }
        
        let (passwordTextField, passwordSignal) = getTextObservable(placeholder: "请输入密码")
        passwordTextField.delegate = self
        view.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(passwordTip.snp.bottom).offset(2)
            make.leading.equalTo(32)
            make.trailing.equalTo(-32)
            make.height.equalTo(34)
        }
        
        
//        nameSignal.subscribe(onNext: { (text) in
//            print("phoneNumber:\(String(describing: text))")
//        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
//        nameSignal.bind(to: ProfileManager.shared.phone).disposed(by: disposeBag)

        
        let phoneValid = numberSignal
            .map {
                $0.count > 0 
        }.share(replay: 1)
        
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints { (make) in
            make.top.equalTo(passwordTextField.snp.bottom).offset(28)
            make.height.equalTo(46)
            make.leading.trailing.equalTo(phoneNumber)
        }
        
        loginButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self, weak phoneNumber] in
            guard let self = self else {return}
            self.loading.startAnimating()
            let random = arc4random_uniform(999999999) + 1
            ProfileManager.shared.loginUserModel = LoginResultModel(userID: "\(random)")
            var temp =  [String : String]();
            temp = ["userId" : ProfileManager.shared.loginUserModel?.userId ?? "",
                    "userNickName" : nameTextField.text ?? "",
                    "password" : passwordTextField.text ?? "",
                    "roomNumber" : phoneNumber?.text ?? "",
                    "userTerminal" : "3",
                    "identity" : "2",
                    "roomVerification" : "0"]
            HPNetManager.post(withUrlString: "http://39.106.88.75:9999/TeacherLive/pages/room/getRoomDetails", isNeedCache: false, parameters: temp, successBlock: { (result) in
                 self.loading.startAnimating()
                if (((result as? [String:Any])?["code"] as? Int) == 200) {
                    self.resultNext = loginModel.mj_object(withKeyValues: ((result as? [String:Any])?["cre"]))
                    ProfileManager.shared.teacherId = self.resultNext.roomTeacherId
//                    [[ProfileManager shared] setTeacherId:self.needDict.roomTeacherId];
                    joinRoom()
                    
                    
                }else{
                    self.loading.stopAnimating()
                    HUDHelper.alert(((result as? [String:Any])?["message"] as? String))
                }
            }, failureBlock: { (error) in
                self.loading.stopAnimating()
            }) { (tempInt, tempInt2) in
                
            }

            
            guard let phoneNumber = phoneNumber else {return}
            phoneNumber.resignFirstResponder()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        phoneValid.bind(to: loginButton.rx.isEnabled).disposed(by: disposeBag)
        phoneValid.subscribe(onNext: { [weak button=loginButton](enabled) in
            button?.alpha = enabled ? 1 : 0.8
            button?.isEnabled = enabled
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        view.addSubview(bottomTip)
        bottomTip.snp.makeConstraints { (make) in
            make.bottomMargin.equalTo(view).offset(-12)
            make.leading.trailing.equalTo(view)
            make.height.equalTo(30)
        }
        
        view.addSubview(versionTip)
        versionTip.snp.makeConstraints { (make) in
            make.bottom.equalTo(bottomTip.snp.top).offset(-2)
            make.height.equalTo(12)
            make.leading.trailing.equalTo(view)
        }
        
        /// auto login
//        if ProfileManager.shared.autoLogin(success: { [weak self] in
//            guard let self = self else {return}
//            if ProfileManager.shared.curUserModel?.name.count == 0 {
////                self.showProfileVC()
//            } else {
//                self.loading.stopAnimating()
//                self.view.makeToast("登录成功")
//                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    //show main vc
//                    AppUtils.shared.showMainController()
//                }
                
                
//                let userID = ProfileManager.shared.curUserID()
//                let userSig = ProfileManager.shared.curUserSig()
//                TRTCCalling.shareInstance().imBusinessID = 1213214
//                TRTCCalling.shareInstance().deviceToken = AppUtils.shared.appDelegate.deviceToken ?? Data()
//                ProfileManager.shared.IMLogin(userSig: "userSig", success: {
//                    TRTCCalling.shareInstance().login(sdkAppID: UInt32(SDKAPPID), user: userID ?? "", userSig: userSig, success: {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                            //show main vc
//                            AppUtils.shared.showMainController()
//                        }
//                    }) { (Int32, String) in
//
//                    }
//                }) { (error) in
//
//                }
//
                
                
//
//            }
//            }, failed: { [weak self] (err) in
//                guard let self = self else {return}
//                self.loading.stopAnimating()
//                self.view.makeToast(err)
//        }) {
//            loading.startAnimating()
//            phoneNumber.text = ProfileManager.shared.curUserModel?.phone ?? ""
//        }
        
        // tap to resign
//        let tap = UITapGestureRecognizer.init()
//        tap.rx.event.subscribe(onNext: { [weak phoneNumber] _ in
//            guard let phoneNumber = phoneNumber else {return}
//            phoneNumber.resignFirstResponder()
//            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
//        view.addGestureRecognizer(tap)
        
//        self.view.endEditing(true)
    }
    
    
    //MARK: - inner functionnd
    func getTextObservable( placeholder:String = "🐉" ) -> (TextField, ControlProperty<String>) {
        let edit = TextField()
        edit.textColor = .white
        edit.dividerThickness = 0.2
        edit.dividerNormalColor = .white
        edit.dividerActiveColor = .appTint
        edit.placeholderNormalColor = UIColor(red: 209.0 / 255.0, green: 209.0 / 255.0, blue: 209.0 / 255.0, alpha: 1.0)
        edit.placeholderActiveColor = UIColor(red: 209.0 / 255.0, green: 209.0 / 255.0, blue: 209.0 / 255.0, alpha: 1.0)
        edit.placeholderLabel.font = Font.boldSystemFont(ofSize: 14)
        view.addSubview(edit)
        edit.placeholder = placeholder
        edit.placeholderAnimation = .hidden
        return (edit, edit.rx.text.orEmpty)
    }
    
    func showProfileVC() {
        let profileVC = ProfileViewController.init()
        navigationController?.pushViewController(profileVC, animated: true)
    }
}

//MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxCount = 11
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= maxCount
    }
    
}
