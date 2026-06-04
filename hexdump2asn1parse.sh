#!/bin/sh
xxd -r -p | openssl asn1parse -inform DER
