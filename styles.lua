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
 -- The build styles define how we build the layers. Please specify:
 --   Speed  : XY speed during motion
 --   height : layer height
 --   width  : width
 --   seglen : segment length
 --
module("styles", package.seeall)

pla = 
{
  
  highq = 
  { 
	  description =  "highq: high quality slow style";
		speed = 30 * 60;  -- extrusion speed [mm/min]	  
		height = 0.04;    -- layer height [mm]
		width = 0.4;      -- line width   [mm]
		seglen = 0.2;     -- target segment length [mm]	
	};

	mediumq =
	{  
	  description =  "mediumq: medium quality style";
		speed = 40 * 60;  -- extrusion speed [mm/min]	  
		height = 0.15;    -- layer height [mm]
		width = 0.5;      -- line width   [mm]
		seglen = 0.6;       -- target segment length [mm]	
	};

	
  -- High speed (lower quality) build style
	highspeed =
	{  
	  description =  "highspeed: high speed style";
		speed = 80 * 60;  -- extrusion speed [mm/min]	  
		height = 0.15;     -- layer height [mm]
		width = 0.5;      -- line width   [mm]
		seglen = 0.6;       -- target segment length [mm]	
	};

}; -- pla
