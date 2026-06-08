#!/bin/bash
echo "Copying all .v files from $1 to $2"
for i in `find $1 -name "*.v"`
do
  cp $i $2
done