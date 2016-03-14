# Compresses contents of subfolders
import os, shutil,  string, zipfile

limdepth = 1# only using 3 first levels on documentation
spath = "/media/andreotti/FetalEKG/2014.10_fecgsyn_simulations(5.0)/wfdb/fecgsyndb/sub02/"
path = os.path.normpath(spath)

# loops through files
for root, subdir, files in os.walk(path):
    if len(files)<10: # just putting some threshold
        continue
    print('The current folder is ' + root)
    #in bash tar -czf zipfile.zip *
    zipname = root.replace("/", "_") # substitute '/' for '_'
    zipname = zipname[-13:] + "_new.zip"
    zf = zipfile.ZipFile(zipname, "w")
    zf.write(root)
    for filename in files:
        zf.write(os.path.join(root,filename))
    zf.close()

    #shutil.move(root+ "/zipfile.zip",spath + namezip)
    
