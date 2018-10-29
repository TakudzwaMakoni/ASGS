# ASGS
(Adaptive Savitsky-Golay Sonifier).  Removes background noise in THEMIS satellite data, converts it into GSM coordinates. Converts that into Audible sound.

July - 2018


resolution of data is 3 seconds.

main functions:

NASASCP - generates level 2 FGM signal, initialises the conversion to GSM using IGRF using satellite state/position files from the NASA Scatterometer Climate Record Pathfinder (SCP) http://www.scp.byu.edu, and FGM data from THEMIS http://themis.ssl.berkeley.edu

SGVOS2 - generates level 2 THEMIS EFI signal in GSM with adaptive SG filter removed from data

L2ESA - generates level 2 THEMIS ESA signal in GSM coordinates with adaptive SG filter removed from data. Velocity / Time taken from https://cdaweb.sci.gsfc.nasa.gov

L2EFI - generates level 2 THEMIS EFI signal in GSM with adaptive SG filter removed from data

SONIF2 - inputs signal data. outputs audible .ogg file at specified sample frequency.




