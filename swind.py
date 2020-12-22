#!/usr/bin/python3

import subprocess
import numpy as np
import re
import logging
import argparse

parser = argparse.ArgumentParser(description="Move windows to monitor corners")
parser.add_argument("position", help="desired position", default="swap")
parser.add_argument("-x", "--width",  type=int, help="monitor width", default=1920)
parser.add_argument("-y", "--height", type=int, help="monitor height", default=1200)
parser.add_argument("-m", "--monitors",type=int, help="number of monitors",  default=2)
parser.add_argument("-s", "--steps",type=int, help="window size steps",  default=5)
parser.add_argument("-d", "--difference",type=int, help="Maximum realtive difference from default",  default=1.5)
parser.add_argument("-t", "--default_size",type=int, help="Default size nomrlized to screen",  default=0.5)
args = parser.parse_args()

logging.basicConfig(filename="/home/tibenszky/.swind.log",level=logging.DEBUG)

#----------------------------------------------------
# Geneargs.default_size the sizes which will be cycled through
tmp=args.width*args.default_size
tmp_1 = np.logspace(np.log10(tmp/args.difference), np.log10(tmp), (args.steps-1)/2, endpoint=False)
tmp_2 = np.logspace(np.log10(tmp), np.log10(tmp*args.difference), (args.steps-1)/2+1, endpoint=True)
l_widths = [int(i) for i in np.concatenate((tmp_1,tmp_2)) ]
print("width list: " + str(l_widths))
logging.debug("width list: " + str(l_widths))

tmp=args.height*args.default_size
tmp_1 = np.logspace(np.log10(tmp/args.difference), np.log10(tmp), (args.steps-1)/2, endpoint=False)
tmp_2 = np.logspace(np.log10(tmp), np.log10(tmp*args.difference), (args.steps-1)/2+1, endpoint=True)
l_heights = [int(i) for i in np.concatenate((tmp_1,tmp_2)) ]
print("height list: " + str(l_heights))
logging.debug("height list: " + str(l_heights))

#----------------------------------------------------
# Get the current window parameters
winid = subprocess.getoutput("xdotool search --name ICADV")
getgeo = subprocess.getoutput("xdotool getwindowgeometry " + winid)
# print(winid)
# print(getgeo)
# It is important to have the \n in the regex. "." does not stand for \n...
m_geo = re.compile(".*\n.*Position: (?P<pos_x>[0-9]+),(?P<pos_y>[0-9]+) \(screen: (?P<screen>[0-9])\).*\n.*Geometry: (?P<width>[0-9]+)x(?P<height>[0-9]+)")
geo=m_geo.match(getgeo)
logging.info("Window ID: " + winid)
logging.info("Window Position X: " + geo.group("pos_x"))
logging.info("Window Position Y: " + geo.group("pos_y"))
logging.info("Screen: " + geo.group("screen"))
logging.info("Window Width: " + geo.group("width"))
logging.info("Window Height: " + geo.group("height"))

#----------------------------------------------------
# Determine the boundary box of the monitors
scr_l=-1
scr_r=-2
if geo.group("screen") == "0":
    scr_l = 0*args.width # screen left
    scr_r = 1*args.width # screen right
elif geo.group("screen") == "1":    
    scr_l = 1*args.width # screen left
    scr_r = 2*args.width # screen right 
else:
    assert "More than two monitors detected."
logging.info("Screen left: "+ str(scr_l))
logging.info("Screen right: "+ str(scr_r))

def newsize( x, y ):
    if x:
        w = int(geo.group("width") )
        if w in l_widths:
            logging.debug(l_widths.index(w))
            new_w = l_widths[ (l_widths.index(w) +1) % len(l_widths)]
            logging.debug("The old width is in our width list")
        else:
            new_w = l_widths[int(len(l_widths)/2)]
            logging.debug("The old width is NOT in our width list")
        logging.info("New width: " + str(new_w))
    else:
        new_w = geo.group("width")
    if y:
        h = int(geo.group("height") )
        if h in l_heights:
            logging.debug(l_heights.index(h))
            new_h = l_heights[ (l_heights.index(h) +1) % len(l_heights)]
            logging.debug("The old width is in our width list")
        else:
            new_h = l_heights[int(len(l_heights)/2)]
            logging.debug("The old width is NOT in our width list")
        logging.info("New width: " + str(new_h))
    else:
        new_h = geo.group("height")
    return (int(new_w), int(new_h)) 
    # resize(new_w, new_h)

def resize( x, y ):
    cmd=["xdotool","windowsize", winid, str(x), str(y)]
    logging.info(cmd)
    subprocess.run(cmd)    

def move( x, y ):
    cmd = ["xdotool","windowmove", winid , str(x), str(y)]   
    logging.info(cmd) 
    subprocess.run(cmd)    

#----------------------------------------------------
# main
if args.position == "top":
    x,y=newsize(False,geo.group("height"))
    resize( args.width, y )
    move( scr_l, 0 )
elif args.position == "bottom":
    x,y=newsize(False,geo.group("height"))
    resize( args.width, y )
    move( scr_l, args.height - y )
elif args.position == "left":
    x,y=newsize(geo.group("width"),False)
    resize( x, args.height )
    move( scr_l, 0 )
elif args.position == "right":
    x,y=newsize(geo.group("width"),False)
    resize( x, args.height)
    move( scr_l + args.width - x, 0 )
elif args.position == "bottom-right":
    x,y=newsize(geo.group("width"),geo.group("height"))
    resize( x, y )
    move( scr_l + args.width - y, args.height - y )
elif args.position == "bottom-left":
    x,y=newsize(geo.group("width"),geo.group("height"))
    resize( x, y )
    move( scr_l, args.height - y )
elif args.position == "top-left":
    x,y=newsize(geo.group("width"),geo.group("height"))
    resize( x, y )
    move( scr_l, 0 )
elif args.position == "top-right":
    x,y=newsize(geo.group("width"),geo.group("height"))
    resize( x, y )
    move( scr_l + args.width - y, 0 )
elif args.position == "swap":
    x=(int(geo.group("pos_x")) + args.width) % (args.monitors*args.width) -1
    y=int(geo.group("pos_y")) - 24
    move( x, y )
