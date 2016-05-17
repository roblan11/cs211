#!/bin/bash

file1 = /Users/r11/Documents/Processing/cs211/Game/
file2 = /Users/r11/Documents/Processing/cs211/rob/

echo "moving folder..."
mv /Users/r11/Documents/Processing/cs211/Game/ /Users/r11/Documents/Processing/cs211/rob/

echo "git add..."
cd /Users/r11/Documents/Processing/cs211/
git add /Users/r11/Documents/Processing/cs211/rob/

echo "git commit..."
echo -n "commit message: "
read mess
git commit -m "$mess"

echo "git push..."
git push

mv /Users/r11/Documents/Processing/cs211/rob/ /Users/r11/Documents/Processing/cs211/Game/
echo "done"
killall Terminal
