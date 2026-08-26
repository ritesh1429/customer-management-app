import os
import sys
import zipfile
import urllib.request
import subprocess

FLUTTER_ZIP_URL = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.47.1-stable.zip"
TARGET_DIR = r"C:\src"
ZIP_PATH = os.path.join(TARGET_DIR, "flutter_sdk.zip")
FLUTTER_BIN = os.path.join(TARGET_DIR, "flutter", "bin", "flutter.bat")

def download_and_setup():
    os.makedirs(TARGET_DIR, exist_ok=True)
    
    if not os.path.exists(FLUTTER_BIN):
        print(f"Downloading Flutter SDK from {FLUTTER_ZIP_URL}...")
        urllib.request.urlretrieve(FLUTTER_ZIP_URL, ZIP_PATH)
        print("Download complete. Extracting Flutter SDK...")
        with zipfile.ZipFile(ZIP_PATH, 'r') as zip_ref:
            zip_ref.extractall(TARGET_DIR)
        print("Extraction complete!")
        if os.path.exists(ZIP_PATH):
            os.remove(ZIP_PATH)
    else:
        print("Flutter SDK already present at", FLUTTER_BIN)

    print("Checking Flutter version...")
    subprocess.run([FLUTTER_BIN, "--version"], check=True)

    print("Building Android APK...")
    app_dir = r"d:\Customer\customer_app"
    result = subprocess.run([FLUTTER_BIN, "build", "apk", "--release"], cwd=app_dir)
    if result.returncode == 0:
        print("\n=======================================================")
        print("   SUCCESS! APK BUILT AT:")
        print(r"   d:\Customer\customer_app\build\app\outputs\flutter-apk\app-release.apk")
        print("=======================================================\n")
    else:
        print("Build exited with code", result.returncode)

if __name__ == "__main__":
    download_and_setup()
