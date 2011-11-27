 --
 -- image.lua
 -- small module to load PGM and BMP files (only uncompressed 8/24bpp)
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
module("image", package.seeall);

-- load bitmap image, call appropriate image file loader based on filename
function load(filename)
  print(filename);
  n = filename;
  if string.find(string.upper(n), ".BMP") ~= nil then
    return loadbmp(filename);
  elseif string.find(string.upper(n), ".PGM") ~= nil then
    return loadpgm(filename);
  else
    print("image.load(): Unknown file format: " .. filename);
  end;
end;



--- PGM file functions
----------------------

--- Get a pixel value
function pgm_getpixel(self,x,y) 
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
function loadpgm(filename)
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
		pixel = pgm_getpixel;
	}
end


--- BMP file functions
----------------------


--- Get a pixel value (only works for 8bpp, pallette is ignored, for 24bpp data returns only the Red component
function bmp_getpixel(self,x,y) 
  if (x < 0) or (y < 0) or (x >= self.w) or (y >= self.h) then
	  return 255;
	else		
    local i = self.start + (((self.h-1)-y)*self.stride) + (x*self.bpp) + 1;
    return self.data:byte(i,i); 
	end;
end;

-- get byte value
function getbyte(self, offset)
  return self:byte(offset+1); 
end;

function getword(self, offset)
  return getbyte(self, offset) + 256 * getbyte(self, offset+1);
end;

function getdword(self, offset)
  return getword(self, offset) + 65536 * getword(self, offset+2);
end;


---
--- loadbmp: read BMP bitmap file
--- Note: we assume 8bits or 24 bits uncompressed files
--- return a table with the data, and a function to access it 
---
function loadbmp(filename)
  if filename == nil then return nil; end;
  f = io.open(filename, "rb");
  if f == nil then return nil; end;
  local img = {};
  img = {
   name = filename;		
	 pixel = bmp_getpixel;  
   data = f:read("*all");  -- read complete file at once
  };
  f:close();    
  if (getbyte(img.data, 0) ~= 66) and  (getbyte(img.data, 1) ~=  77 ) then
    print("This is not a BMP file!");
    return nil;
  end;
  img.start = getdword(img.data,10);   -- start of data offset
  img.hdrsize = getdword(img.data, 14);  
  img.w = getdword(img.data,18);  -- width
  img.h = math.abs(getdword(img.data,22));   --  height (negative means inverted top/down, not handled)
  img.bpp = getword(img.data,28) / 8; -- bytes per pixel   
  img.compression = getdword(img.data, 30); -- compression (0 is no compression, the only handled case)
  img.stride = 4*math.ceil( (img.w * img.bpp * 8) / 32 ); -- bytes from one line to another
  if img.compression ~= 0 then
    print("bmp.load(): compression=" .. img.compression .. ". That is not supported!");
  end;
  if img.bpp ~= 1 and img.bpp ~= 3 then
    print("bmp.load(): number of bits-per-pixel is not supported, should be 8 or 24!");
  end
  -- test(img);
	return img;
end


-- test BMP loader function, echo BMP file content on the console as ASCII data
function test(img)
  for y = 0,img.h-1 do  
    s = "|";
    for x = 0,img.w do
      if img:pixel(x,y) > 0 then 
        s = s .. "*";
      else
        s = s .. " ";
      end;
    end;
    print(s .. "|");
  end;
  print(img.name .. ": len=" .. img.data:len() .. " hdrsize=" .. img.hdrsize .. ", size=" .. img.w .. "x" .. img.h .. ", bpp=" .. img.bpp ..", compression=" .. img.compression .. ", start=" .. img.start ..", stride=".. img.stride);
end;


