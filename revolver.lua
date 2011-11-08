 --
 -- revolver.lua
 -- A lua script to make circular shapes, based on an input bitmap.
 -- Requires lua version > 5.1.4
 --
 --  Copyright (c) 2011 Peter Brier
 -- 
 --  This file is part of the revolver project
 -- 
 --    revolver is free software: you can redistribute it and/or modify
 --    it under the terms of the GNU General Public License as published by
 --    the Free Software Foundation, either version 3 of the License, or
 --    (at your option) any later version.
 -- 
 --    revolver is distributed in the hope that it will be useful,
 --    but WITHOUT ANY WARRANTY; without even the implied warranty of
 --    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 --    GNU General Public License for more details.
 -- 
 --    You should have received a copy of the GNU General Public License
 --    along with revolver.  If not, see <http://www.gnu.org/licenses/>.
 --  
 -- 
 -- use: lua revolver.lua [config file]
 --
 --
require "pgm"        -- PGM bitmap file reader
require "gcode"      -- gcode file writer
require "materials"  -- material definitions
require "styles"     -- material definitions
require "rendervase" -- vase renderer


---
--- Main
---
name = arg[1] or "shape.lua";
oname = name .. ".gcode";
dofile(name); -- load the shape

print("revolver.lua: Creating gcode file " .. oname .. " from input file " .. name );
print("Using style: " .. shape.style.description);
print("Using material: " .. shape.material.description);

gc = gcode.new(oname);

-- dump settings to file as comments
gc:comment(" -- Generated with revolver.lua -- ");
gc:comment(os.date());
gc:comment("Shape: ", shape);

gc:copyfile("start.gcode");
gc:comment("Homing:");
gc:home();

-- Set the style parameters for extruder scaling and speed
gc:escale(shape.style.width*shape.material.efactor, shape.style.height, shape.material.diameter, shape.style.speed);
gc:temperature(shape.material.tbuild);
gc:fan(100);
gc:move(nil,nil,nil,6, 50); -- extrude some material


-- make the shape
shape:render(gc);

-- stop code
gc:move(0,0);
gc:fan(0);
gc:temperature(shape.material.tstandby);
gc:copyfile("end.gcode");
print("\nDone.\n");

-- Conversion for visualisation
-- os.execute("../gcode2vtk/gcode2vtk.exe " .. oname);


-- EOF



