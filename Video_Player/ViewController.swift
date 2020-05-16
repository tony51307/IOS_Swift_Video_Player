//
//  ViewController.swift
//  Video_Player
//
//  Created by Tony Lee on 2020/5/13.
//  Copyright © 2020 Tony Li. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit


class ViewController: UIViewController {
    
    var player = AVPlayer()
    var playing = false
    var videos = [URL]()
    var count=0
    
    var Repeat = false
    
    private lazy var layer : AVPlayerLayer = {
        let playeritem = AVPlayerItem(url: videos[count])
        self.player = AVPlayer()
        self.player.replaceCurrentItem(with: playeritem)
        let layer = AVPlayerLayer(player: self.player)
        let duration = playeritem.asset.duration
        let seconds = CMTimeGetSeconds(duration)
        progress.text = formatConversion(time: 0)
        
        
        player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using: {(CMTime) in let currentTime = CMTimeGetSeconds(self.player.currentTime())
            self.progressSlider.minimumValue = 0
            self.progressSlider.maximumValue = Float(CMTimeGetSeconds((self.player.currentItem?.asset.duration)!))
            self.progressSlider.value = Float(currentTime)
            self.progress.text = self.formatConversion(time: currentTime)
        })
        
        
        return layer
    }()
    
    func formatConversion(time: Float64) -> String{
        let songLength = Int(time)
        let minutes = Int(songLength / 60)
        let seconds = Int(songLength % 60)
        var time = ""
        if minutes < 10{
            time = "0\(minutes):"
        } else {
            time = "\(minutes)"
        }
        if seconds < 10 {
            time += "0\(seconds)"
        }else{
            time += "\(seconds)"
        }
        return time
    }
    
    @IBOutlet weak var mode: UILabel!
    @IBOutlet weak var progress: UILabel!
    @IBAction func back5(_ sender: UIButton) {
        let seekDuration = Float64(5)
        let targetTime = CMTimeGetSeconds(self.player.currentTime()) - seekDuration
        if targetTime > 0 {
            
            let time2 = CMTimeMakeWithSeconds(targetTime,preferredTimescale: 1000)
            player.seek(to: time2)
        }else{
            let time2 = CMTimeMakeWithSeconds(0,preferredTimescale: 1000)
            player.seek(to: time2)
        }
    }
    
    @IBAction func next5(_ sender: UIButton) {
        let seekDuration = Float64(5)
        let targetTime = CMTimeGetSeconds(self.player.currentTime()) + seekDuration
        if targetTime <= CMTimeGetSeconds(player.currentItem?.asset.duration ?? self.player.currentTime()) {
            
            let time2 = CMTimeMakeWithSeconds(targetTime,preferredTimescale: 1000)
            player.seek(to: time2)
        }else{
            let time2 = CMTimeMakeWithSeconds(CMTimeGetSeconds(player.currentItem?.asset.duration ?? self.player.currentTime()),preferredTimescale: 1000)
            player.seek(to: time2)
        }
    }
    @IBAction func previous(_ sender: UIButton) {
        if count == 0{
            count=videos.count-1
        }else{
            count=count-1
        }
        if playing == false{
            playBotton.setImage(UIImage(named: "play.png"), for: .normal)
            let playeritem = AVPlayerItem(url: videos[count])
            player.replaceCurrentItem(with: playeritem)
        }else{
            playVideo(playBotton)
            playBotton.setImage(UIImage(named: "play.png"), for: .normal)
            let playeritem = AVPlayerItem(url: videos[count])
            player.replaceCurrentItem(with: playeritem)
            playVideo(playBotton)
        }
    }
    @IBOutlet weak var nextButton: UIButton!
    @IBAction func next(_ sender: UIButton) {
        if count == videos.count-1{
            count=0
        }else{
            count=count+1
        }
        if playing == false{
            playBotton.setImage(UIImage(named: "play.png"), for: .normal)
            let playeritem = AVPlayerItem(url: videos[count])
            player.replaceCurrentItem(with: playeritem)
        }else{
            playVideo(playBotton)
            playBotton.setImage(UIImage(named: "play.png"), for: .normal)
            let playeritem = AVPlayerItem(url: videos[count])
            player.replaceCurrentItem(with: playeritem)
            playVideo(playBotton)
        }
    }
    
    @IBOutlet weak var progressSlider: UISlider!
    
    @IBAction func changeTime(_ sender: UISlider) {
        let seconds =  Int64(progressSlider.value)
        let targetTime: CMTime = CMTimeMake(value: seconds, timescale: 1)
        player.seek(to: targetTime)
    }
    
    @IBAction func volumnSlider(_ sender: UISlider) {
        player.volume = sender.value
    }
    @IBOutlet weak var playBotton: UIButton!
    @IBAction func playVideo(_ sender: UIButton) {
        if playing == false{
            playBotton.setImage(UIImage(named: "pause.png"), for: .normal)
            player.play()
            playing = true
        }else{
            playBotton.setImage(UIImage(named: "play.png"), for: .normal)
            player.pause()
            playing = false
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        videos.append(URL(fileURLWithPath: Bundle.main.path(forResource: "video1", ofType:"mp4")!))
        videos.append(URL(fileURLWithPath: Bundle.main.path(forResource: "video2", ofType:"mp4")!))
        videos.append(URL(fileURLWithPath: Bundle.main.path(forResource: "video3", ofType:"mp4")!))
        
        
        player.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        
        
        view.layer.addSublayer(self.layer)
    }
    
    @objc func playerItemDidReachEnd(notification: Notification){
        if let playerItem = notification.object as? AVPlayerItem {
            if Repeat == true{
                playerItem.seek(to: CMTime.zero)
                playVideo(playBotton)
                playVideo(playBotton)
            }else{
                playVideo(playBotton)
                next(nextButton)
                playVideo(playBotton)
            }
        }
    }

    
    @IBAction func `continue`(_ sender: UIButton) {
        Repeat = false
        mode.text = "循序播放 mode"
    }
    @IBAction func loop(_ sender: UIButton) {
        Repeat = true
        mode.text = "循環播放 mode"
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layer.frame = view.bounds
    }
    
    
}


