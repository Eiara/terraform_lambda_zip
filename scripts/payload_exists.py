
import sys
import re
import json
import glob, os
import datetime

var = json.loads(sys.stdin.read())
# We expect there to be:
# name
# output path

# let's check the output path for what we're looking for here

path = "{0}/{1}".format( var["output_path"], "%s_*_payload.zip" % var["name"] )

files = glob.glob(path)
# woo

if not files:
    # okay we have no files
    # We generate a new indicator and return that
    identifier = int(datetime.datetime.now().strftime("%s"))
    sys.stdout.write(json.dumps({"identifier": str(identifier)}, indent=2))
    sys.exit(0)

if files:
    # Cool, we have an existing file. Go us!
    if len(files) > 1:
        print("ERROR: More than one payload file exists for %s" % var["name"])
        sys.exit(1)
    r = re.compile("%s_([0-9]+)_payload.zip" % var["name"])
    file_ = os.path.basename(files[0])
    identifier = r.match(file_).groups()[0]
    if not identifier:
        print("ERROR: Couldn't find identifier in existing file")
        sys.exit(1)
    sys.stdout.write(json.dumps({"identifier": str(identifier)}, indent=2))
    sys.exit(0)