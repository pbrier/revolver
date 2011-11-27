 --
 -- bmp.lua
 -- small module to load BMP files (only uncompressed 24bpp)
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
module("bmp", package.seeall)

--- Get a pixel value (only works for 8bpp, pallette is ignored, for 24bpp data returns only the Red component
function getpixel(self,x,y) 
  if (x < 0) or (y < 0) or (x >= self.w) or (y >= self.h) then
	  return 255;
	else		
    idx = self.start + ((self.h-1)-y)*self.stride+(x*self.bpp)+1;
   -- print(self.start, self.stride, self.w, self.h, self.bpp, x, y, idx);
    return self.data:byte( idx ); 
	end;
end;

-- get byte value
function getbyte(self, offset)
  if offset > self:len() then 
    return nil; 
  else 
    return self:byte(offset+1); 
  end;
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
function load(filename)
  if filename == nil then return nil; end;
  f = io.open(filename, "rb");
  if f == nil then return nil; end;
  local img = {};
  img = {
   name = filename;		
	 pixel = getpixel;  
   data = f:read("*all");  -- read complete file at once
   save = save;
  };
  f:close();    
  if (getbyte(img.data, 0) ~= 66) and  (getbyte(img.data, 1) ~=  77 ) then
    print("This is not a BMP file!");
    return nil;
  end;
  img.start = getdword(img.data,10);   -- start of data offset
  if img.start == 1074 then img.start = 1078; end; -- dunno why, but MS-PAINT seems to miss 4 bytes when writing 8bpp images
  img.w = getdword(img.data,18);  -- width
  img.h = math.abs(getdword(img.data,22));   --  height (negative means inverted top/down, not handled)
  img.pasize = getdword(img.data, 34); -- pixel array size
  img.bpp = getword(img.data,28) / 8; -- bytes per pixel   
  img.compression = getdword(img.data, 30); -- compression (0 is no compression, the only handled case)
  img.stride = 4*math.ceil( (img.w * img.bpp * 8) / 32 ); -- bytes from one line to another
  if img.compression ~= 0 then
    print("bmp.load(): compression=" .. img.compression .. ". That is not supported!");
  end;
  if img.bpp ~= 1 and img.bpp ~= 3 then
    print("bmp.load(): number of bits-per-pixel is not supported, should be 8 or 24!");
  end
	return img;
end


-- Save BMP file (data)
function save(self,filename)
  if filename == nil then return nil; end;
  f = io.open(filename, "wb");
  f:write(self.data);
  f:close();
end;  
  
  
-- test BMP loader function, echo BMP file content on the console
function test(name)
  img = load(name);
  -- img:save(name .. ".bmp");
  for y = 0,img.h-1 do  
    s = "|";
    for x = 0,img.w-1 do
      if img:pixel(x,y) > 0 then 
        s = s .. "*";
      else
        s = s .. " ";
      end;
    end;
    
    print(s .. "|");
  end;
  print(img.name ..": size=" .. img.w .. "x" .. img.h .. ", bpp=" .. img.bpp ..", compression=" .. img.compression );
  print("start=" .. img.start .. "stride=" .. img.stride .. "pasize=" .. img.pasize );
end;


-- test("hello.bmp");