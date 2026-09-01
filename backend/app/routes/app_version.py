from fastapi import APIRouter

router = APIRouter(prefix="/app", tags=["App Version"])

# App Version Metadata Configuration
APP_VERSION_INFO = {
    "latest_version": "1.0.1",
    "latest_version_code": 2,
    "download_url": "https://github.com/ritesh1429/customer-management-app/releases/latest/download/app-release.apk",
    "release_notes": "Added Search by Father's Name and A-Z Alphabetical Fast Scroll Bar.",
    "force_update": False,
}

@router.get("/version")
def get_latest_app_version():
    """Get the latest mobile application release version and APK download link."""
    return APP_VERSION_INFO
