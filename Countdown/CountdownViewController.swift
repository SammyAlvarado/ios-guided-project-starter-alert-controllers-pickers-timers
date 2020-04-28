//
//  CountdownViewController.swift
//  Countdown
//
//  Created by Paul Solt on 5/8/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import UIKit

class CountdownViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var countdownPicker: UIPickerView!
    
    // MARK: - Properties
    
    private let countdown = Countdown()
    
    var dateFormatter: DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SS" //
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        return formatter
    }() // This is a intance
    
    private var duration: TimeInterval {
        // Convert From minutes + second to total seconds
        let minuteString = countdownPicker.selectedRow(inComponent: 0)
        let secondString = countdownPicker.selectedRow(inComponent: 2)
        
        let minutes = Int(minuteString)
        let seconds = Int(secondString)
        
        let totalSeconds = TimeInterval(minutes * 60 + seconds)
        return totalSeconds
    }
    
    lazy private var countdownPickerData: [[String]] = {
        // Create string arrays using numbers wrapped in string values: ["0", "1", ... "60"]
        let minutes: [String] = Array(0...60).map { String($0) }
        let seconds: [String] = Array(0...59).map { String($0) }
        
        // "min" and "sec" are the unit labels
        let data: [[String]] = [minutes, ["min"], seconds, ["sec"]]
        return data
    }()
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        countdownPicker.dataSource = self
        countdownPicker.delegate = self
        
        //
        countdownPicker.selectRow(1, inComponent: 0, animated: false)
        countdownPicker.selectRow(30, inComponent: 2, animated: false)
        countdown.duration = duration
        countdown.delegate = self
        
        
        // Use ad fixed width font, so numbers don't "pop" and update Ui to show duration
        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeLabel.font.pointSize, weight: .medium)
        startButton.layer.cornerRadius = 4.0
        resetButton.layer.cornerRadius = 4.0
        updateViews()
    }
    
    // MARK: - Actions
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        countdown.start()
//        let timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: timerFinished(timer:))
    }
    
    private func timerFinished(timer: Timer) {
        showAlert()
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        countdown.reset()
        updateViews()
    }
    
    // MARK: - Private
    
    private func showAlert() {
        //1: Initialize new instance of alert
        let alert = UIAlertController(title: "Timer Finisehed ", message: "Your Countdonw is Over", preferredStyle: .alert)
        
        // 2. Creat Alert Actions
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        // 3. Add Action
        alert.addAction(okAction)
        
        // 4. Present alert
        self.present(alert, animated: true, completion: nil)
    }
    
    private func updateViews() {
        startButton.isEnabled = true
        
        switch countdown.state {
        case .started:
            timeLabel.text = string(from: countdown.timeRemaining)
        case .finished:
            timeLabel.text = string(from: 0)
        case .reset:
            timeLabel.text = string(from: countdown.duration)
        }
    }
    
    private func string(from duration: TimeInterval) -> String {
       let date = Date(timeIntervalSinceReferenceDate: duration)
        return dateFormatter.string(from: date)
    }
}

extension CountdownViewController: CountdownDelegate {
    func countdownDidUpdate(timeRemaining: TimeInterval) {
        updateViews()
        
    }
    
    func countdownDidFinish() {
        updateViews()
        self.showAlert()
    }
}

extension CountdownViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        #warning("Change this to return the number of components for the picker view")
        return countdownPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        #warning("Change this to return the number of rows per component in the picker view")
        return countdownPickerData[component].count
    }
}

extension CountdownViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let timeValue = countdownPickerData[component][row]
        return String(timeValue)
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 50
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countdown.duration = duration
        updateViews()
    }
    
}
