 --
 --  rendervase.lua
 --  Direct gcode rendering of a 3D vase, based on bitmaps
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
module("vase", package.seeall)


-- no modulator
function no_modulator(r,a,z)
  return 0;
end;

-- sine waveform modulator
function sine_modulator(r,a,z)
  return 0.1*z* math.sin(10*a);
end;

-- Bitmap modulator, take a point from a bitmap and use its intensity to modify the local radius
function bmp_modulator(r,a,z)
  local i = shape.timage;
	local x,y = math.floor(i.w - ((a * i.w)  / (2 * math.pi)) ), math.floor(i.h-((z * i.h) / shape.size.height));	
  return shape.modulation * (i:pixel(x % i.w, y)/255);
end;

-- make a ring, center is at 'pos', starting at r0, upto r1
-- adjust astep, to make it an integer division of 2*pi 
-- Call the "modulator" function on all points to calculate a possible radius offset
function ring(gc, pos, r0, r1, astart, astep, modulator1, modulator2)
  local r, rstep, n;  
	n = 10 + math.ceil( 2*math.pi/astep ); -- minimum of 11 segments
	astep = 2.0*math.pi / n;
	rstep = (r1-r0) / (2.0*math.pi / astep);
	r = r0;
	ra =  r + modulator1(r,0,pos.z) + modulator2(r,0,pos.z);
	local x = pos.x + ra * math.sin(astart);
	local y = pos.y + ra * math.cos(astart);
  if (math.abs(x - gc.x) > 0.6) then xm = x; else xm = gc.x; end; -- suppress small XY moves
  if (math.abs(y - gc.y) > 0.6) then ym = y; else ym = gc.y; end;
  gc:move(xm,ym,pos.z);
	
  for a = astart, astart+2*math.pi+0.001, astep do		  
	  r = r + rstep;			
	  ra = r + modulator1(r,a,pos.z) + modulator2(r,a,pos.z);
    gc:extrude( pos.x + ra * math.sin(a), pos.y + ra * math.cos(a));
  end
end;


-- Make a disk from R0 to R1 with steps of DR
function disk(gc, pos, r0, r1, dr, seglen, modulator1, modulator2)
  if astart == nil then 
	  astart = 0; 
	 else 
	   astart = astart + 0.1;  
	end;
	astart = 2*math.pi*math.random();
	astart = 0;	
		
	if dir == nil then dir = false; end;
	dir = not dir;
	
	if dir then
	  rstart,rend,rstep = r0,r1,dr;
	else
		rstart,rend,rstep = r1,r0,-dr;
  end;
	
	
   for r = rstart, rend+0.0001, rstep do	      	  
		 ring(gc, pos, r, r, astart, seglen / r, modulator1, modulator2);
  end
end


-- Return image edge (first or last black pixel)
function leftedge(image, y)
  for ix = 0,image.w-1 do
	  if image:pixel(ix,y) == 0 then
		  return ix;
		end;
  end;
	return image.w;
end;
function rightedge(image, y)
  for ix = image.w-1, 0, -1 do
	  if image:pixel(ix,y) == 0 then
		  return ix;
		end;
  end;
	return 0;
end;


-- Output the shape
-- R0 and R1 are read from the image. 
-- The first black pixel is used as R0 and the last as R1
-- We adjust R0, R1 and DR based on the style settings
-- the outer shells are inset by havle the line width, the r0 and dr are calculated to match 
-- we start at start angle 'astart' and move in steps with a predefined segment length

function render(self,gc)

  self.image = pgm.load(self.contour);
	self.timage = pgm.load(self.texture);
	local img = self.image;
  local pos = self.pos;
	local w = self.size.width;
	local h = self.size.height, z;
	
	if self.modulator == nil then self.modulator = no_modulator; end;
	self.bmpmodulator = no_modulator;
	
	if self.frequency ~= nil then self.modulator = sine_modulator; end;
	
	if  self.image == nil then
	  print("can't open contour image: " .. self.contour);
	  os.exit();
	else
	  print( "Countour image: " .. self.image.name .. " (" .. img.w .. "x" .. img.h .. " pixels)" ) ;
	end;
	
	if self.timage ~= nil then
	  print( "Texture image: " .. self.timage.name .. " (" .. self.timage.w .. "x" .. self.timage.h .. " pixels)" );
  	self.bmpmodulator = bmp_modulator;
	end;
		
	-- for all layers:
  for z=pos.z+0.5*self.style.height, h, self.style.height do 
	  iy = math.floor( (img.h-1) - ((img.h * z) / h) );
		r0 = (leftedge(img, iy) * w/2.0) / img.w;
		r1 = (rightedge(img, iy) * w/2.0) / img.w;	
    dr = self.style.width;
		r0 = r0 + dr/2;  -- left: inset by adding halve the linewidth
		r1 = r1 - dr/2;  -- right: inset by substracting halve the linewidth
		
		t = self.thickness or (r1-r0); -- thickness (if defined in shape, or taken from the image)
		if self.min_thickness then -- minimal wall thickness
		  if t < self.min_thickness then t = self.min_thickness; end;
		end;
		
		n = math.floor(0.5+ (t / self.style.width) ); -- calculate the number of shells
    if n == 0 then n = 1; end; -- always 1 shell at least
		r0 = r1 - n * dr; -- recalc start radius
	  pos.z = z;
		gc:setpos(nil,nil,nil,0); -- zero E each layer
    disk(gc, pos, r0, r1, dr, self.style.seglen, self.modulator, self.bmpmodulator);
		io.write("Z: " .. gcode.round(pos.z,2) .. "mm  (" .. gcode.round(100 * pos.z / h,0) .. "%) " .. gcode.round(t,2) .. "mm wall " .. n .. " shells " .. gcode.round(dr,2) .. "mm step                              \r");
		-- io.write("Z: " .. pos.z .. " iy=" .. iy .. " r0=" .. r0 .. " r1=" .. r1 .. "                                    \r");
		io.flush();
  end;
end;
