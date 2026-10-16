# OS/2 Port of Charles Petzold's OS/2 Presentation Manager programs (1994) to fpc

# Source (C)

Charles Petzold's OS/2 Presentation Manager Programming, 1994.
The original sources can be compiled with e.g. Borland CPP 2, IBM Cset 2 or IBM VAC 3.  

# Source (Pascal)

Code is organized per chapter of the book; each program has its own subdirectory.
The ch00 directory has code to "compensate for"/replace the C macros.  

# Compilation

For compilation the following are recommended:
- fpc 3.2.2
- RC 5.00.007 (Jan 30 2003) (needed for the hexcalc programs only)  

Most of it can also be compiled with fpc 2.6.4 and/or RC 4.00.011 (Oct 10 2000).  

For a quick approach:
- copy the command files in commandfiles one level up (so to its parent directory)
- run mall.cmd
- run goxall.cmd
- run runall.cmd  

# Some limitations

On fpc side:
- requires emx to be available
- cannot produce dll's (shared libraries); use Virtual pascal 2.1 instead  
  
On the programs:
- freemem is too optimistic (but the C versions don't do better)
- printcal can (sometimes) mess up (shrink) the font size for the month in PS output; screen tends to be OK.  

# Motivation

Why this project: learn C/C++. Next, see how far fpc gets under OS/2. Most of it was done around 2021; this excludes the use of AI.  
