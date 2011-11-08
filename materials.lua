 --
 --  materials.lua
 --  gcode generator in lua - Material definitions
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
module("materials", package.seeall)

-- Material types
pla =
 {
   standard3mm =
   {
	   description = "standard3mm: 3mm black PLA";   -- just for information
     name = "PLA";																 --
	   color = "black";                              --
 	   diameter = 2.85;                              -- Filament diameter
 	   tstart = 230;                                 -- first layer temperature
	   tbuild = 240;                                 -- other layer temperature
	   tstandby = 100;                               -- temp at end of build
		 efactor = 1.0;                                -- extruder multiplier (larger is more material, default = 1.0)
   };
	 
	 soft3mm =
   {
	   description = "soft3mm: 3mm soft PLA";
     name = "PLA";
	   color = "white";
 	   diameter = 2.85;
 	   tstart = 230;
	   tbuild = 240;
	   tstandby = 100;
		 efactor = 1.3; -- extruder scaling
   };
	 
}

