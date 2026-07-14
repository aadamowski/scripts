#!/usr/bin/env python3
#
# Description: Sets a file's modification time based on its EXIF DateTimeOriginal tag.
# Dependencies: python3, exifread
# Usage: python3 exif_timestamps_to_file_modtime_in_curdir.py
# Author: Aleksander Adamowski

import exifread
import os
import time
import sys

def get_exif_timestamp(filename):
    with open(filename, 'rb') as f:
        tags = exifread.process_file(f, stop_tag='DateTimeOriginal')
        return tags.get('EXIF DateTimeOriginal')

def exif_ts_to_unix_ts(exif_ts):
    # exif_ts is an ExifDateTime object
    # exif_ts.values is a string like "2023:01:01 12:00:00"
    return time.mktime(time.strptime(exif_ts.values, "%Y:%m:%d %H:%M:%S"))

def set_file_ts_from_exif(filename, exif_ts):
    if exif_ts:
        try:
            unix_ts = exif_ts_to_unix_ts(exif_ts)
            os.utime(filename, (unix_ts, unix_ts))
            print(f"{filename} timestamp set to: {unix_ts} ({exif_ts.values})")
        except (ValueError, KeyError, time.error) as e:
            print(f"Error parsing EXIF timestamp in {filename}: {e}", file=sys.stderr)

def main():
    for filename in os.listdir('.'):
        if not os.path.isfile(filename):
            continue
        try:
            exif_ts = get_exif_timestamp(filename)
            if exif_ts:
                set_file_ts_from_exif(filename, exif_ts)
        except Exception as e:
            print(f"ERROR when processing file {filename}: {e}", file=sys.stderr)

if __name__ == '__main__':
    main()

