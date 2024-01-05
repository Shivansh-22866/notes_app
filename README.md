# Flutter Notes App

A flutter project in submission for Winter Dev Wonderland - NIT Goa Coding Club

## Getting Started

This project is the implementation of the third problem statement of the Winter Dev Wonderland - to create a Notes app.
The app has the following features:
  - CRUD operations on any note
  - Search feature to find a note by its title or content
  - Categorization of notes on the basis of their Importance - Critical, Essential, Relevant, Routine, Trivial
  - Every note can have upto 6 images and 4 videos and any of them can be removed or added while editing.

Some extra features that have been implemented:
  - Sort notes on the basis of last modified time
  - Sort notes on the basis of their importance category
  - Export notes in form of text file (.txt), HTML file, (.html), and PDF (.pdf)
  - Custom animation has been added while transitioning between the edit screen and home screen of the notes app.
  - Splash Screen at the launch of the app.


## Dart packages used:
  -   cupertino_icons: ^1.0.2
  -   image_picker: ^1.0.5
  -   video_player: ^2.8.1
  -   video_thumbnail: ^0.5.3
  -   flutter_image_compress: ^2.1.0
  -   shared_preferences: ^2.2.2
  -   share: ^2.0.4
  -   pdf: ^3.10.7
  -   path_provider: ^2.1.1
  -   img: ^0.1.0
  -   animated_splash_screen: ^1.3.0
  -   chewie: ^1.7.4
  -   flutter_launcher_icons: ^0.13.1

## Font assets used:
    - family: Archivo
      fonts:
        - asset: assets/fonts/Archivo/Archivo-Italic-VariableFont_wdth,wght.ttf
        - asset: assets/fonts/Archivo/Archivo-VariableFont_wdth,wght.ttf
          style: italic
    - family: PTSans
      fonts:
        - asset: assets/fonts/PT_Sans_Narrow/PTSansNarrow-Regular.ttf
        - asset: assets/fonts/PT_Sans_Narrow/PTSansNarrow-Bold.ttf
          weight: 700

### To get started, here are some of the resources that I used:
  - [Basic UI for notes app](https://www.youtube.com/watch?v=4Na6MF_9tIE)
  - [Splash Screens in flutter](https://www.youtube.com/watch?v=XXISgdYHdYw)
  - [Creating custom launcher icons for the flutter app](https://www.youtube.com/watch?v=QPVMaedX1W8)
  - [Generating and adding content in a PDF on flutter](https://www.youtube.com/watch?v=8j6GKtpRkow)
  - [Data persistence through shared_preferences package](https://www.youtube.com/watch?v=hiZcVbyukBo)
  - [Dropdown Button Form Field for better looking dropdown lists](https://www.youtube.com/watch?v=6_Azs3fq9O4)
