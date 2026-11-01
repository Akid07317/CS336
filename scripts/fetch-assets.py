"""Restore upstream fixtures excluded from Git; never fetch training datasets implicitly."""
import hashlib
import json
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def digest(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def main():
    assignment = sys.argv[1]
    entries = json.loads((ROOT / "upstream-assets.json").read_text())
    for entry in entries:
        if entry["assignment"] != assignment:
            continue
        destination = ROOT / entry["path"]
        if destination.is_file() and digest(destination) == entry["sha256"]:
            print("OK", entry["path"])
            continue
        if destination.exists():
            raise RuntimeError(f"Refusing to overwrite modified fixture: {destination}")
        print("Downloading", entry["path"], flush=True)
        destination.parent.mkdir(parents=True, exist_ok=True)
        temporary = destination.with_name(destination.name + ".partial")
        try:
            with urllib.request.urlopen(entry["url"], timeout=120) as response, temporary.open("wb") as output:
                while chunk := response.read(1024 * 1024):
                    output.write(chunk)
            if digest(temporary) != entry["sha256"]:
                raise RuntimeError(f"SHA256 mismatch: {destination}")
            temporary.replace(destination)
        finally:
            temporary.unlink(missing_ok=True)


if __name__ == "__main__":
    main()
