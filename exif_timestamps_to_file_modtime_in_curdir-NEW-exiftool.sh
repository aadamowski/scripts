#!/bin/bash

exiftool -api QuickTimeUTC "-FileCreateDate<CreateDate" "-FileModifyDate<CreateDate" *.[Mm][Oo][Vv]
exiftool -ext jpg -ext heic -extractEmbedded "-FileCreateDate<DateTimeOriginal" "-FileModifyDate<DateTimeOriginal" *.[Hh][Ee][Ii][Cc] *.[Jj][Pp][Ee][Gg] *.[Jj][Pp][Gg]
