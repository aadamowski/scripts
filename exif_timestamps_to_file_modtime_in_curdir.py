#!/usr/bin/env python

import exifread
import os
import time



def get_exif_timestamp(filename):
    with open(filename) as f:
        tags = exifread.process_file(f, stop_tag='DateTimeOriginal')
        #print tags.keys()
        return tags.get('EXIF DateTimeOriginal')

def exif_ts_to_unix_ts(exif_ts):
    return time.mktime(time.strptime(exif_ts.values, "%Y:%m:%d %H:%M:%S"))

def set_file_ts_from_exif(filename, exif_ts):
    if exif_ts:
        unix_ts = exif_ts_to_unix_ts(exif_ts)
        os.utime(filename, (unix_ts, unix_ts))
        print filename + ' timestamp set to: ' + str(unix_ts) + ' (' + exif_ts.values + ')'


def main():
    for filename in os.listdir('.'):
        if not os.path.isfile(filename):
            continue
        try:
            exif_ts = get_exif_timestamp(filename)
            set_file_ts_from_exif(filename, exif_ts)
        except:
            print 'ERROR when processing file ' + filename

if __name__ == '__main__':
    main()
