import fnmatch
import os
import sys

path=sys.argv[1]
matches_m1 = []
for root, dirnames, filenames in os.walk(path):
    for filename in fnmatch.filter(filenames, '*m1.fif'):
        matches_m1.append(os.path.join(root, filename))
        
matches_m2 = []
for root, dirnames, filenames in os.walk(path):
    for filename in fnmatch.filter(filenames, '*m2.fif'):
        matches_m2.append(os.path.join(root, filename))

thefile = open('m1.txt', 'w')
for item in matches_m1:
  thefile.write("%s\n" % item)
thefile.close()

thefile = open('m2.txt', 'w')
for item in matches_m2:
  thefile.write("%s\n" % item)
thefile.close()
