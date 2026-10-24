import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
data = {}
if path.exists():
    try:
        data = json.loads(path.read_text())
    except Exception:
        data = {}
if "githubReviews" in data:
    raise SystemExit(0)
data["githubReviews"] = {"enabled": True, "trigger": "r "}
path.write_text(json.dumps(data, indent=2) + "\n")
