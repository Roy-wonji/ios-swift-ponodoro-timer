//
//  ViewController.swift
//  pamodoro
//
//  Created by 서원지 on 2021/10/19.
//

import UIKit
import AudioToolbox

enum TimerStatus{
    case start
    case pause
    case end
    
}


class ViewController: UIViewController {

    @IBOutlet var timerlabel: UILabel!
    @IBOutlet var progreeView: UIProgressView!
    @IBOutlet var datePicker: UIDatePicker!
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var toggleButton: UIButton!
    
    var duration = 60
    var timerStatus: TimerStatus = .end
    var timer: DispatchSourceTimer?
    var currentSenconds = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureToggleButton()
        // Do any additional setup after loading the view.
    }

    func setTimerInfoViewVisble(isHidden: Bool) {
        self.timerlabel.isHidden = isHidden
        self.progreeView.isHidden = isHidden
    }
    
    func configureToggleButton() {
        self.toggleButton.setTitle("시작", for: .normal)
        self.toggleButton.setTitle("일시정지", for: .selected)
    }
    
    func startTimer(){
        if self.timer ==  nil {
            self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            self.timer?.schedule(deadline: .now(),repeating: 1)
            self.timer?.setEventHandler(handler: {[weak self] in
                guard let self = self else{ return }
                self.currentSenconds -= 1
                let hour = self.currentSenconds / 3600
                let minutes = (self.currentSenconds % 3600) / 60
                let seconds = (self.currentSenconds % 3600) % 60
                self.timerlabel.text = String(format: "%02d:%02d:%02d", hour,minutes,seconds)
                self.progreeView.progress = Float(self.currentSenconds) / Float(self.duration)
                UIView.animate(withDuration: 0.5 , delay: 0   , animations: {
                    self.imageView.transform = CGAffineTransform(rotationAngle:  .pi)
                })
                UIView.animate(withDuration: 0.5, delay: 0.5,  animations: {
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi * 2)
                    
                })
                
                if self.currentSenconds <= 0 {
                    self.stopTimer()
                    AudioServicesPlaySystemSound(1005)
                }
            })
            self.timer?.resume()
        }
    }
    
    
    func stopTimer() {
        if self.timerStatus == .pause{
            self.timer?.resume()
            
        }
        self.timerStatus = .end
        self.cancelButton.isEnabled = false
        UIView.animate(withDuration: 0.5, animations: {
            self.timerlabel.alpha = 0
            self.progreeView.alpha = 0
            self.datePicker.alpha = 1
            self.imageView.transform = .identity
            
        })
        self.toggleButton.isSelected = false
        self.timer?.cancel()
        self.title = nil
        
    }
    
    
    @IBAction func tapCancelButton(_ sender: UIButton) {
        switch self .timerStatus {
                case .start, .pause:
                self.stopTimer()
            
        default:
            break
        }
    }
    
    @IBAction func tapToggleButton(_ sender: UIButton) {
        self.duration = Int(self.datePicker.countDownDuration)
        switch self.timerStatus{
        case .end:
            self.currentSenconds = self.duration
            self.timerStatus = .start
            UIView.animate(withDuration: 0.5, animations: {
                self.timerlabel.alpha = 1
                self.progreeView.alpha = 1
                self.datePicker.alpha = 0
            })
            self.toggleButton.isSelected = true
            self.cancelButton.isEnabled = true
            self.startTimer()
            
        case .start:
            self.timerStatus = .pause
            self.toggleButton.isSelected = false
            self.timer?.suspend()
            
        case .pause:
            self.timerStatus = .start
            self.toggleButton.isSelected = true
            self.timer?.resume()
            
        default:
            break
        }
    }
}

