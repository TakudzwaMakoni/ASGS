# ASGS
(Adaptive Savitsky-Golay Sonifier).  Removes background noise in THEMIS satellite data, converts it into GSM coordinates. Converts that into Audible sound.

July - 2018


resolution of data is 3 seconds.

Functions:
SONIF2 - inputs signal data. outputs audible GSM orientated signal at specified sample frequency.

L2ESA - generates level 2 THEMIS ESA signal in GSM with adaptive SG filter removed from data. Velocity / Time taken from https://cdaweb.sci.gsfc.nasa.gov

L2EFI - generates level 2 THEMIS EFI signal in GSM with adaptive SG filter removed from data

NASASCP - generates level 2 FGM signal in GSM using satellite state/position files from the NASA Scatterometer Climate Record Pathfinder (SCP) http://www.scp.byu.edu, and FGM data from THEMIS http://themis.ssl.berkeley.edu
