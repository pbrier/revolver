 --
 -- pgm.lua
 -- small module to load PGM files
 -- Copyright (c) 2011 Peter Brier
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
module("pgm", package.seeall)

--- Get a pixel value
function getpixel(self,x,y) 
  if (x < 0) or (y < 0) or (x >= self.w) or (y >= self.h) then
	  return 255;
	else
		i = y*self.w*self.d+(x*self.d)+1; 
    return self.data:byte(i,i); 
	end;
end;


---
--- loadpgm: read PGM (portable graymap) bitmap file
--- Note: we assume 8bits binary grayscale GIMP pgm file (with one comment line)	
--- return a table with the data, and a function to access it 
---
function load(filename)
  if filename == nil then return nil; end;
  f = io.open(filename, "rb");
  hdr1 = f:read("*line"); -- P5
  hdr2 = f:read("*line"); -- # creator
  hdr3 = f:read("*line"); -- 32 32
  hdr4 = f:read("*line"); -- 255
  size = {};
  i = 0;
  for token in string.gmatch(hdr3, "[^%s]+") do
   size[i] = token;
	 i = i+1;
  end
	return -- return class with content
	{
    w = tonumber(size[0]); 
    h = tonumber(size[1]);
		d = 1; -- assume 1 byte per pixel
    data = f:read("*all");
		name = filename;		
		pixel = getpixel;
	}
end
