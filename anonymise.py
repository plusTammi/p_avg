import fnmatch
import os
import sys
import mne
import re
import errno    

def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else:
            raise


path=sys.argv[1]
matches = []
for root, dirnames, filenames in os.walk(path):
    for filename in fnmatch.filter(filenames, '*.fif'):
        matches.append(os.path.join(root, filename))


change=[]
case_numb=[]
for i in matches:
	folders=i.split('/')
	if folders[-1][1:5]!=folders[-3][-4:]:
		matchObj = re.match( r'case_\d{4}',folders[-3])
		if not matchObj:
			change+=[i]
			try:
				raw=mne.io.Raw(i, preload=False,verbose=False)
				case_numb+=[raw.info['subject_info']['id']]
			except:
				case_numb+=[folders[-1][1:5]]
print change
for idx,i in  enumerate(change):
	folders=i.split('/')
	folders[-3]='case_'+str(case_numb[idx])
	f=os.path.join('/',*folders)
	folders=os.path.join('/',*folders[:-1])
	mkdir_p(folders)
	print
	print f
	print
	try:
		raw=mne.io.Raw(i, preload=True,verbose=False)
		raw.anonymize()
		raw.save(f,fmt='short',overwrite=True)
		os.remove(i)
	except:
		print "Could not move "+i
	print f


