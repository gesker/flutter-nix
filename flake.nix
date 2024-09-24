{
  description = "Flutter environment";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (
      system:
      let

        # Note: Update these values in the ./optionsFlutterCreate.nix
        inherit (import ./optionsFlutterCreate.nix)
          flutterOrganization
          flutterProjectName
          flutterProjectDescription
          flutterProjectFolder
          ;

        inherit (nixpkgs) lib config;

        pkgs = import nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };

        emulatorPlatform = "34";

        android = {
          versions = {
            #toolsVersion = "26.1.1"; # Deprecated
            cmdLineToolsVersion = "13.0";
            platformTools = "35.0.1";
            buildTools = "34.0.0";
            ndk = [ "26.3.11579264" ];
            cmake = "3.22.1";
            emulator = "35.1.4";
          };

          platforms = [
            emulatorPlatform
            "29"
          ];
          systemImageTypes = [
            "google_apis"
            "google_apis_playstore"
          ];
          abis = [
            "x86"
            "x86_64"
            "armeabi-v7a"
            "arm64-v8a"
          ];

          extras = [ "extras;google;gcm" ];

          extraLicenses = [
            "android-sdk-license"
            "android-googletv-license"
            "android-sdk-arm-dbt-license"
            "android-sdk-license"
            "android-sdk-preview-license"
            "google-gdk-license"
            "intel-android-extra-license"
            "intel-android-sysimage-license"
            "mips-android-sysimage-license"
          ];
        };

        androidEnv.licenseAccepted = true;
        androidComposition = pkgs.androidenv.composeAndroidPackages {

          # Android
          #toolsVersion = android.versions.toolsVersion; # Deprecated
          cmdLineToolsVersion = android.versions.cmdLineToolsVersion;
          platformToolsVersion = android.versions.platformTools;
          buildToolsVersions = [ android.versions.buildTools ];
          platformVersions = android.platforms;
          abiVersions = android.abis;

          # Images and Emulator
          includeSources = true;
          includeSystemImages = false;
          includeEmulator = true;
          emulatorVersion = android.versions.emulator;

          # NDK
          includeNDK = true;
          ndkVersions = android.versions.ndk;
          cmakeVersions = [ android.versions.cmake ];

          # Addittional APIs
          useGoogleAPIs = true;
          includeExtras = android.extras;

          # Accept _All_ Licenses
          extraLicenses = android.extraLicenses;
        };

        flutterPackage = pkgs.flutter;
        jdkPackage = pkgs.jdk17;
        androidSdk = androidComposition.androidsdk;
        androidPlatformTools = androidComposition.platform-tools;
        # Only install Android Studio on Linux - Not Darwin (Apple)
        isInstallAndroidStudio = if (pkgs.stdenv.hostPlatform.isDarwin) then false else true;

        androidEmulator = pkgs.androidenv.emulateApp {
          name = "emulate-android-nix";
          platformVersion = emulatorPlatform;
          abiVersion = "x86_64";
          systemImageType = "google_apis_playstore";
        };

      in
      {
        devShell =
          with pkgs;
          mkShell rec {
            name = "flutter-nix";

            buildInputs = [
              flutterPackage
              jdkPackage
              androidSdk
              androidPlatformTools
              androidEmulator
              google-chrome
              gradle
              qemu_kvm
            ] ++ lib.optionals isInstallAndroidStudio [ android-studio ];

            ANDROID_NDK_ROOT = "${androidSdk}/libexec/android-sdk/ndk-bundle";
            ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
            CHROME_EXECUTABLE = "${pkgs.google-chrome}/bin/google-chrome-stable";
            CMAKE_ROOT = "${androidSdk}/cmake/${android.versions.cmake}";
            DART_ROOT = "${flutterPackage}/bin/cache/dart-sdk";
            FLUTTER_ROOT = flutterPackage;
            GRADLE_HOME = ".gradle"; # Keep pub-cache in this folder
            GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/libexec/android-sdk/build-tools/${android.versions.buildTools}/aapt2";
            JAVA_HOME = jdkPackage.home;
            LANG = "C.UTF-8";
            LC_ALL = "C.UTF-8";
            PUB_CACHE = ".pub-cache";

            # Suppress Zsh Timeout
            DIRENV_WARN_TIMEOUT = 0;

            # Emulator Related
            QT_QPA_PLATFORM = "wayland;xcb"; # Try Wayland; Fallback to X11
            LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath [
              vulkan-loader
              libGL
            ]}";

            # Flutter Create
            FLUTTER_ORGANIZATION = flutterOrganization;
            FLUTTER_PROJECT_NAME = flutterProjectName;
            FLUTTER_PROJECT_DESCRIPTION = flutterProjectDescription;
            FLUTTER_PROJECT_FOLDER = flutterProjectFolder;

            shellHook = ''
              export PROJECT_ROOT=$(git rev-parse --show-toplevel)
              echo
              echo "reached nix develop shellHook"
            '';

          };
      }
    );
}

