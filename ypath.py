from os.path import join, split, basename, dirname, normpath
from shutil import which
print(normpath(join(dirname(which('yosys')), '..','share','yosys','include')))

