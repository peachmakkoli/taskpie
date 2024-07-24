# 🥧 TaskPie 🥧

TaskPie is a time management and task planning app for Android and iOS, intended to help users visualize how much of the day is devoted to different tasks and
better estimate how long a task will take via recording tools.

The first version of TaskPie was developed by Theo Moon (he/they), formerly known as Lee Higgins, using Flutter SDK and Firebase from July 6-24th, 2020 to satisfy his Capstone project for [Ada Developers Academy](https://adadevelopersacademy.org/), Cohort 13. This app is a work in progress with future enhancements planned. Check back later for updates!

Click for a demo:
[![TaskPie Main Screen](https://i.imgur.com/tqwuaWn.png)](https://youtu.be/-evC9avD0hI)

## 🥧 Contents

1. [Features](#-features)
2. [Installation Guide](#-installation-guide)
3. [Dependencies](#-dependencies)
4. [Trello Board](https://trello.com/b/PiePJUPH/taskpie-app)
5. [Acknowledgements](#-acknowledgements)

## 🥧 Features

Current features are marked with a check, and planned features will be completed during 2020-2021 as time allows.
##### As a user...
- [x] I want to be able to log into the app using Google or email/password. **(MVP)**
- [x] I want my calendar to look like a circle representing a 24-hour clock, which is split into "pie slices," each representing a single task, so I can see all of the day's activities and what percentage of the day they take up. **(MVP)**
- [x] I want to be able to create and update tasks via a form. **(MVP)**
- [x] I want to be able to view task details by tapping on a pie slice, including buttons to edit or delete the event. **(MVP)**
- [x] I want to be able to assign categories to my tasks (e.g., sleeping, eating, socializing, etc.), so I can view how much of my day those categories take up (with color coding).
- [x] I want to be able to record how long it takes to complete a task, so I can better predict the time needed for that task in the future.
- [x] I want to be prompted by push notifications when a task is approaching and ending, so I can be reminded to record time.
- [ ] I want a stats page that shows me my daily average time spent in each category, given a date range.
- [ ] I want a settings button in the top bar that opens up a menu where I can see my name, a logout button, a button to access my task stats, and be able to switch between day and night mode.
- [ ] I want to be able to import my tasks from Google Calendar (or from a CSV file), so I do not have to recreate tasks I've already entered elsewhere. (Note: Overlapping tasks are not yet supported.)
- [ ] I want to be able to set a custom start and end hour for my calendar, so I can define the boundaries of my day (e.g., day starts when I wake up at 8am)
- [ ] I want to be able to share my calendar with friends by superimposing their pie chart over mine, so I can easily see where our free time aligns and plan tasks together.

## 🥧 Installation Guide

#### 1. Install Flutter SDK, Android Studio, and XCode for your operating system
- https://flutter.dev/docs/get-started/install

#### 2. Set up your editor of choice
- https://flutter.dev/docs/get-started/editor

#### 3. Add Firebase
- iOS: https://firebase.google.com/docs/flutter/setup?platform=ios
- Android: https://firebase.google.com/docs/flutter/setup?platform=android
- *For Android, add SHA certificate fingerprints*: https://developers.google.com/android/guides/client-auth

#### 4. Add Syncfusion
1. Apply for a free Community License: https://www.syncfusion.com/products/communitylicense
2. Generate Syncfusion license key: https://help.syncfusion.com/common/essential-studio/licensing/license-key
3. Create a `.env` file in the top directory of the app (i.e., /taskpie)
4. Add `SF_LICENSE_KEY=`, followed by your license key

#### 5. Check your setup
Run the following commands in order:
1. `flutter doctor`, follow instructions to solve any errors
2. `flutter clean`
3. `flutter pub get`
4. `cd ios`
5. `pod install`
6. `pod repo update`
7. `pod update`

#### 6. Run the app!
- To run the app on a specific device, run `flutter devices` on the command line and note the name of your device. Then run `flutter run -d` followed by the name or ID of your device.
- Otherwise, run `flutter run -d all` to run on all connected devices.

## 🥧 Dependencies

### Mobile Platform
- Android 5.0 'Lollipop' or higher (SDK Vers. 21+)
- iOS 10.0 or higher

### Flutter Packages & Plugins

#### *UX*
- [Cloud Firestore](https://pub.dev/packages/cloud_firestore): ^0.13.7
- [Google Sign In](https://pub.dev/packages/google_sign_in): ^4.5.1
- [Flutter DotENV](https://pub.dev/packages/flutter_dotenv): ^2.1.0
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications): ^1.4.4+2
- [Firebase Auth](https://pub.dev/packages/firebase_auth): ^0.16.1
- [Firebase Auth OAuth](https://pub.dev/packages/firebase_auth_oauth): ^0.1.1+1
- [One Context](https://pub.dev/packages/one_context): ^0.4.0
- [RXDart](https://pub.dev/packages/rxdart): ^0.23.1
- [Wakelock](https://pub.dev/packages/wakelock): ^0.1.4+2

#### *UI*
- [Card Settings](https://pub.dev/packages/card_settings): ^1.11.0
- [Cupertino Icons](https://pub.dev/packages/cupertino_icons): ^0.1.3
- [Custom Horizontal Calendar](https://pub.dev/packages/custom_horizontal_calendar): ^0.1.3
- [Google Fonts](https://pub.dev/packages/google_fonts): ^1.1.0
- [Expandable Bottom Sheet](https://pub.dev/packages/expandable_bottom_sheet): ^0.2.1+1 
- [Flutter Launcher Icons](https://pub.dev/packages/flutter_launcher_icons): ^0.7.2
- [Flutter Login](https://pub.dev/packages/flutter_login): ^1.0.14
- [Syncfusion Flutter Charts](https://pub.dev/packages/syncfusion_flutter_charts): ^18.2.44
- [UnicornDial](https://pub.dev/packages/unicorndial): ^1.1.5

## 🥧 Acknowledgements

This app would not be possible without the support of the following individuals and organizations: 

- [Ada Developers Academy](https://adadevelopersacademy.org/), a non-profit, tuition-free coding school for women and gender diverse adults, which focuses on serving low income people, underrepresented minorities, and members of the LGBTQIA+ community.

- Cohort 13, the fiercest, most tenacious bunch of software developers I have ever known. We completed our capstone projects in just three weeks during a global pandemic, national protests for Black racial justice, and countless personal hurdles. Many of us had zero experience with coding prior to entering Ada Developers Academy. I am so proud of us and all that we have achieved!

- The Flutter Capstones Slack channel, a.k.a. #geniuslevelideas, who kept each other company with jokes, laughter, commiseration, and development support throughout the process.

- My roommate, friends with ADHD, and teachers at Ada Developers Academy, who inspired the idea for this app and helped me bring it to life.

- My family and friends who contributed to my crowdfund and made it possible for me to move to Seattle to attend Ada Developers Academy. 

- And [Freepik](http://www.freepik.com/), for providing this cute icon for the app logo!

![TaskPie logo](https://imgur.com/AV22W8h.png)
