REVOLVER
~~~~~~~~
A program to make 3D vases (or other round shapes) using bitmap files
(c) 2011 P. Brier pbrier.nl /.at./ gmail.com


PREFACE
~~~~~~~
This program generates GCODE files for your 3D printing, from bitmap files.
How does it work: you define a shape using a bitmap. This shape is converted to
a circular shape, with the contour you have drawn in the bitmap.

The bitmap should have a WHITE BACKGROUND and the contour of the shape should 
be drawn in BLACK.

LUA (www.lua.org) is used to convert the contour into a shape. Download the right
lua version (at least version 5.1.4) for your platform, and extract all the files in 
the same folder as the revolver scripts. Some versions of linux ship with an older
version of lua (5.1) this may not work. Download the right version (in source
or binary).

NOTE: revolver generates GCODE for 3D printers with "Volumetric 5D" firmware. That 
means the "E" parameter specifies the "absolute length of filament" in milimeter
that is fed into the extruder. For example: the "marlin" and "sprinter" 
firmware for the Ultimaker machine can be used. 

You may need to calibrate the "steps per mm" for the extruder (using the M92 code).
This can be done in the "start.gcode" file that you can place in the same directory
as the revolver script.

Toolpath generation is generally quick (10 to 100 second range). So it is not stopping
you experimenting with the parameters of your shape.


FUNCTIONS
~~~~~~~~~
You can make circular shapes, of any size, with any (variable) wall thickness. 
The shape can be defined and modified by:
- A bitmap file that specifies the contour of the shape
- A bitmap file that is used as a "texture" to modify the surface of the contour
- A mathematical function that is used to specify the shape

See the "shape.lua" and the examples for some information on the various parameters that
define the shape.


USE
~~~
Use this command to generate your shape:

	lua revolver.lua <your shape file>

If you do not specify a shape file, the default file "shape.lua" is used, and "shape.lua.gcode" is 
generated.

The "shape.lua" file defines the shape to make, and there are a number of settings you
can change. Make a copy of the file and modify it to your taste. The new shape file can
be specified on the command line:

  lua revolver.lue hello.lua

this will generate hello.lua.gcode.




BITMAP FILES
~~~~~~~~~~~~
Revolver uses grayscale, binary PGM (portable gray map) image files. You can use GIMP to 
make these bitmaps. Also the NETPBM and ImageMagik tools can be used to make or convert
these files. Make sure you select the "binary" (P5) file format when saving the files.
In windows, the "Irfanview" program can also be used to read, write and convert these image
files. Also, a program like Inkscape, or even "Paint" can be used to make your bitmaps.


TOOL PATH GENERATION
~~~~~~~~~~~~~~~~~~~~
Because the tool path is generated from a mathematical description of the shape (that is derived
from the bitmap) is does not suffer from common problems that arise when you convert a 3D shape in
an STL file to a GCODE toolpath. The generator makes concentric rings, that are defined in terms
of ANGLE and RADIUS. The linear toolpath segment are calculated with a predefined SEGMENT LENGTH. 
(almost) all segments will have this length, independent of the radius of the shape. This way, you
can make smooth surfaces, at a constant number of segments per second. You can define the segment length in 
the styles.lua file. "High quality" values are in the 0.1 to 1 mm range. Use larger values when using
faster extrusion speeds, as you may "overstress" the firmware if the number is too small (causing too much
segments per segment to be executed by the firmware, typically at levels of more than 200 segments/second).


MATERIALS AND STYLES
~~~~~~~~~~~~~~~~~~~~
To calibrate the gcode generation process for your machine and material, you may have to
change the material definition and build style. See the "materials.lua" and 
"styles.lua" files. You can add additional defintions of materials and styles, and
use them in "shape.lua".

The only parameter you may have to change is the filament thickness and layer height/width.
If too little material is extruded for a givent width and hight, you may also modify the "efactor"
parameter in the material definition. 1.0 is default, a lower number extracts LESS material and
a higher number MORE material. For example: efactor=0.5 HALVES the ammount of material, and 
efactor=2.0 DOUBLES the ammount of material.


SENDING THE FILE
~~~~~~~~~~~~~~~~
Use ReplicatorG, Pronterface or SENDG to send the file to the printer, or place the file on the SD
card of your printer.


PREVIEWING THE FILE
~~~~~~~~~~~~~~~~~~~
Because the gcode toolpath is not a 3D STL file, you may have problems previewing your file before you print it.
A program like "GCODE2VTK" combined with "PARAVIEW" can be used to convert and view the gcode file in 3D.
I may add a preview function, if requested by popular demand :-)


HELP!!! I'VE GOT A LUA ERROR MESSAGE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Most likely you made a typo in the shape file (missing a semicolon, comma, space?)
check the error message, it is usually quite accurate in pinpointing the problem:

For example:

lua: helloworld.lua:28: '}' expected near 'z'
stack traceback:
        [C]: in function 'dofile'
        revolver.lua:39: in main chunk
        [C]: ?
				
This could indicate you forgot to place a semicolon (;) before the "z". Because of that
it is expecting a "}" character. Check line 28 of helloworld.lua, as indicated by the message.

Another one:

lua: revolver.lua:43: attempt to index field 'material' (a nil value)
stack traceback:
        revolver.lua:43: in main chunk
        [C]: ?

This is a bit more tricky, as LUA reports a variable (material) is not defined (a nil value) 
somewhere in the "revolver.lua" file. The problem is NOT in the "revolver.lua" file.
The material is assigned in the "shape.lua" and you probably made a type when specifying 
the material there, or when defining that material in the "materials.lua" file.

See www.lua.org for more information and the syntax of the language.







