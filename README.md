# TimerApp

This is simple timer app for iOS.  
It let us select the duration of timer and then pause/resume and stop it. It fires notification upon finishing timer if app is in background.

<p align="left">
<img src="https://user-images.githubusercontent.com/14185009/202363161-f304d574-561d-4d9d-8e25-1eba2252337c.png" width="200">
<img src="https://user-images.githubusercontent.com/14185009/202363792-a44996ff-4428-4db6-8de4-513cf056d980.png" width="200">
<img src="https://user-images.githubusercontent.com/14185009/202364474-8a5b0ad1-7931-4c04-97f8-3a0bb3f1b244.png" width="200">
</p>

### Features
This app let us schedule a timer for selected duration in minutes.  
Upon starting, it'll show remaining time (minutes, seconds and milliseconds) and animated ring around it.  
Once timer is finished then app will show such alert and if app is in background or killed then it'll fire a system notification.  
Once timer is started then app will continue to count-down, even if app is put in background or killed.
It also let us pause the timer, upon pausing it persists the current state of timer and let us resume it anytime within same app life cycle or different (after killing and re-launching the app).  

### Tech Specs
XCode 14.1  
UI- SwiftUI  
Min Supported iOS 15

### Limitations
This app can run only one timer at a time.  
Need modifications to run multiple timers simultaneously.
                                                                                                                        
