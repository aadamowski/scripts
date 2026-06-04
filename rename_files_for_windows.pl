#!/bin/sh
rename_files_perl_expression.pl '[\ \|\&\?\!\*\[\]\(\)]+' '_'
rename_files_perl_expression.pl '\_{2,}' '_'
