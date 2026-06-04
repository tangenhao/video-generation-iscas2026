#!/bin/bash

for((i=0;i<=29;i+=1))
do
{
  echo "$i:"
  grep -C 3 "mismatch number is     " ./work/$i/sim/work/run.log | head -4
}
done