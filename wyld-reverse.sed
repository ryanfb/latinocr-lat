#!/bin/sh
sed '
s/Â/ffi/g
s/Ã/ffl/g
s/Á/ff/g
s/À/ct/g
s/Ä/fi/g
s/Å/fl/g
s/È/sh/g
s/É/si/g
s/Ê/sl/g
s/Ë/ss/g
s/Ì/st/g
s/Ç/ſ/g
/^♙.*$/d' $1
