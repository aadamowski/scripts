#!/bin/bash

echo $(( ( RANDOM % ($2 - $1 + 1 ) ) + $1 ));
