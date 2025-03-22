# flutter-flake-develop-simple

A very simple [flutter](https://flutter.dev/) environment using packages provided by [nix package manager](https://nixos.org/download/).


# pre-requisites

- [Nix Package Manager](https://nixos.org/download/)
- [direnv](https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=direnv) 
  - direnv [homepage](https://direnv.net/) 

# usage

## tldr

clone repo, update variables in [optionsFlutterCreate.nix](optionsFlutterCreate.nix) and push to your own git repo

## detailed

- clone repository
  - `git clone https://github.com/gesker/flutter-flake-develop-simple`
- delete .git folder
  -  `rm -rf flutter-flake-develop-simple/.git`
- cd into folder
  - `cd flutter-flake-develop-simple` 
- Update variables in [optionsFlutterCreate.nix](optionsFlutterCreate.nix)
  - values in  [optionsFlutterCreate.nix](optionsFlutterCreate.nix) are used in execution of `flutter create` command
  - **Note**: The default folder specified for the flutter project `myproject` is already in [.gitignore](.gitignore)
  - The value of `flutterProjectFolder` in [optionsFlutterCreate.nix](optionsFlutterCreate.nix) can be an actual new sub-folder where your flutter project will be created OR it can be `.`
    - If set to `.` I would recommend renaming the folder `flutter-env-nix` to the name of your project
- **Take a good look at the following 2 files**
  -  [flake.nix](flake.nix)
      - Composes [Android](https://www.android.com/) environment in similar fashion as described at [wiki.nixos.org](https://wiki.nixos.org/wiki/Android#)
      - Downloads and installed required software packaged from the [NixOS repository](https://github.com/NixOS)
        - [Unstable Branch](https://github.com/NixOS/nixpkgs/tree/nixpkgs-unstable) has the most recent versions published by NixOS project
      - Sets _MOST_ environment variables
        - ANDROID_NDK_ROOT
        - ANDROID_SDK_ROOT
        - CHROME_EXECUTABLE
        - CMAKE_ROOT
        - DART_ROOT
        - FLUTTER_ROOT
        - GRADLE_HOME
          - Default is `.gradle` in _THIS_ directory 
        - GRADLE_OPTS
        - JAVA_HOME
        - LANG
        - LC_ALL
        - PUB_CACHE
          - Default is `.pub-cache` in _THIS_ directory
  - [.envrc](.envrc)
      - These commands will be run by the direnv utility
      - Mostly output of _ALL_ environment variables set in this project and the output of the `flutter doctor` command    
    - Sets _REMAINING_ environment variables
        - ANDROID_USER_HOME
        - ANDROID_AVD_HOME
        - PATH
          - Ensures that `cmake` [provided by the Android project](https://developer.android.com/studio/projects/install-ndk#default-version) is _first_ in **PATH**
          - Ensures that the `.pub-cache` subdirectory is _last_ in **PATH**
  - run `direnv allow`
  - run `git init`, `git remote add origin ...`, `git push`, etc.

# to-do (_possibly_)

- [ ] decide if Android/Sdk needs to be linked to $HOME/Android/Sdk
  - So far this does not seem to be necessary 
- [ ] build [Android](https://www.android.com/) and [Android Studio](https://developer.android.com/studio) based on values in [flake.nix](flake.nix)
  - Copy routines from NixOS repo ??
  - Currently just using the most recent versions Android tools provided by NixOS
- [ ] [fastlane](https://docs.fastlane.tools/getting-started/cross-platform/flutter/) template and [github actions](https://docs.github.com/en/actions) ??
- [ ] verify emulator on [MacOS](https://www.apple.com/macos)

# tips/hints

- Android Studio is **NOT** installed on [MacOS](https://www.apple.com/macos)
- Project can still be accessed from outside the project
- Consider adding plugins to Android Studio that work with direnv
