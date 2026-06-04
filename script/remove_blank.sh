#!/bin/bash
 
for file in $1/*
do
  echo $file
  sed -i '/^[[:space:]]*$/d' $file
done