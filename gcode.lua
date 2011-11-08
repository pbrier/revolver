 --
 --  gcode.lua
 --  gcode writer functions in lua
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
module(..., package.seeall)

-- gcode (static) class
gcode = 
{
}

-- create gcode file writer class, return instance of the gcode class
function new(name)
  o = 
	{ 
	  x=0; y=0; z=0; e=0, f=0;	 -- current position	
    lx=0, ly=0, lz=0, le=0, lf=0; -- last emitted position
    decimals = 2;     -- nr of decimal places in output coordinates
    edecimals = 3;    -- nr of decimal places E axis output
    epermm = 0.1;     -- extrusion per mm of travel
    mspeed = 60*60;   -- move speed (between extrusions)
    espeed = 60*30;   -- Extrusion speed};   -- create object   		
  };
	o.filename = name;
	o.file = io.open(name, "wb"); 	
	setmetatable(o, gcode)
  gcode.__index = gcode;
  return o
end

-- emit any remaining lines, and close file
function gcode.close(self)  
  self:emit();
  io.close(self.file); 	
	self.file = nil;
end;

-- copy the contect of a file into the current gcode file
function gcode.copyfile(self,name)
  self:emit();
	self:comment("<-- Including file: " .. name .. " -->");
  local fh = io.open(name, "r");
	if  fh ~= nil  then 
		for l in fh:lines() do 
			gc:write(l); 
		end;
		fh:close();
	end;
	self:comment("<-- End of include file: " .. name .. " -->");
end;

-- Calculate the feedrate factor, based on layer width,height and filament diameter, assume square profile
function gcode.escale(self,w,h,d,speed)
  self.epermm = w*h / ((math.pi*d*d)/4);	
	if speed ~= nil then
	  self.espeed = speed;
	end;
end

-- write data to file
function gcode.write(self, line)
  self.file:write(line .. "\n");
end;

-- return a string with the content of a table in space delimmited key=value pairs (recursive)
local function dumptable(t)
  local s = " {";
  for i,v in pairs(t) do 	
	  if type(v) == "table" then
		  s = s .. " " .. dumptable(v);
		elseif type(v) == "function" then s = s .. " (function) ";
		else
      s = s .. " " ..i .. "=" .. v .. " ";
		end;		
	end;
	return s .. "} ";
end;


-- write comment to file
function gcode.comment(self,s,t)
  self:emit();
  self:write("( " .. s .. " )" );
	if t == nil then return; end;	
  for i,v in pairs(t) do 	
	  if type(v) == "function" then s = " (function) ";
		elseif type(v) == "table" then s = dumptable(v);
		else 
		  s = v;
		end;
	  self:write("(   " .. i .. " = " .. s .. " )" ) 
	end;
end;


-- move current position, pass nil values to axis values to -not- change this field
function gcode.move(self,x,y,z,e,f)
	self.x = x or self.x;
	self.y = y or self.y;
  self.z = z or self.z;
	self.e = e or self.e;
  self.f = f or self.mspeed;	-- default is move-speed
end;


-- set current position
function gcode.setpos(self, x, y, z, e)
  self:emit();
  s = "";
	if x ~= nil then self.x = x; s = s .. " X" .. x; end;
	if y ~= nil then self.y = y; s = s .. " Y" .. y; end;
	if z ~= nil then self.z = z; s = s .. " Z" .. z; end;	
  if e ~= nil then self.e = e; s = s .. " E" .. e; end;		
	if s ~= ""  then  self:write("G92 " .. s .. " (set current position)"); end;
end;

-- move home, and set units to mm abs
function gcode.home(self, x, y, z)
  self:emit();
  s = "";
  if x ~= nil then s = s .. " X"; end;
	if y ~= nil then s = s .. " Y"; end;
	if z ~= nil then s = s .. " Z"; end;
	self:write("G28" .. s .. " (home)");
  self:write("G21 (units mm)");
	self:write("G90 (abs pos)");	
	self:setpos(x,y,z,0);
end;

-- move to a position, while extruding
function gcode.extrude(self, x, y, z)
  self:emit(); -- emit any moves or previous extrude commands
  dx = (x or self.x) - self.x;
	dy = (y or self.y) - self.y;
	dz = (z or self.z) - self.z;
	self.f = self.espeed;
  self.x = self.x + dx;
	self.y = self.y + dy;
	self.z = self.z + dz;
  self.e = self.e + self.epermm  * math.sqrt( dx*dx + dy*dy + dz*dz );	
  self:emit();
end;

-- set speed
function gcode.speed(self,f)
  self.f = f;
end;

-- set temperature
function gcode.temperature(self,t)
  self:emit();
  self:write("M104 S" .. t .. " (set temperature)");
end;

-- set fan (0..100%)
function gcode.fan(self,fan)
  self:emit();
  fan = fan or 0; -- default is off
  if fan < 0 then fan = 0; end;
	if fan > 100 then fan = 100; end;
  if fan == 0 then
	  self:write("M107 (fan off)");
	else	  
	  self:write("M106 S" .. fan * 2.55 .. " (set fan on S=0..255)" );
	end;
end;

-- emit the current position to the file, emit nothing if no value has changed (or if only F has changed)
function gcode.emit(self, extra)
  s = "";
	if self.lx - self.x ~= 0 then s = s .. " X" .. round(self.x,self.decimals); end;
	if self.ly - self.y ~= 0 then s = s .. " Y" .. round(self.y,self.decimals); end;
	if self.lz - self.z ~= 0 then s = s .. " Z" .. round(self.z,self.decimals); end;
	if self.le - self.e ~= 0 then s = s .. " E" .. round(self.e,self.edecimals); end;	
	self.lx = self.x;
	self.ly = self.y;
	self.lz = self.z;
	self.le = self.e;	
	if  s ~= "" then
	  if self.lf - self.f ~= 0 then s = s .. " F" .. round(self.f,1); self.lf = self.f; end;
	  s = "G1" .. s .. (extra or "");
	  self:write(s);
	end;
end;

-- Hop to new location, this causes z to raise, xy to move and z to lower again (to original z, or new z if supplied)
function gcode.hop(self, x, y, dz, z)
  dz = dz or 1.0; -- default is 1 mm
  cz = self.z;
  self:move(nil,nil,self.z+dz); 	self:emit();
	self:move(x,y); self:emit();
	self:move(nil,nil,z or cz); self:emit();
end;

-- round to nearest decimal places
function round(val, decimal)
  if (decimal) then
    return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
  else
    return math.floor(val+0.5)
  end
end
