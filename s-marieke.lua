-- shape.lua
-- Example of a shape to make
-- Peter Brier
-- Input for revolver.lua
--
-- a shape should select a render methode (currently only vase.render)
-- and set the parameters for the shape
--  * pos {x,y,z}    center of the shape
--  * size {w,h,d}   size of the shape (in x,y,z direction)
--  * style          build style (e.g. styles.pla.highq)
--  * material       the material used (e.g. materials.pla.standard3mm)
--
-- other fields are shape type specific
-- for a vase:
--  * contour        contour bitmap file name. A binary grayscale ".PGM" image, where black pixels define the left and right side of the contour
--  * texture        texture bitmap file name. This is "wrapped" around the shape (horizontal direction=360deg rotation, vertical directions = height)
--  * modulation     scalar that is multiplied with the texture intensity value to get the modulation of the radius
--  * modulator      a function that returns a radius offset for a give (r,a,z) value where r=radius, a=angle, z=height.
--                   for example: modulator = function(r,a,z)  return 0.1*z* math.sin(10*a); end;
--  * thickness      [mm] constant wall thickness. If not defined, the wall thickness depends on the 
--  * min_thickness  [mm] Minimal wall thickness. If not defined, "1 shell" is used as minimal wall thickness
shape =
{
  render = vase.render;  										 -- the type of shape
	material = materials.pla.standard3mm;      -- material
	style = styles.pla.highspeed;              -- build style
	size = 	{	width = 50; height = 70; };      -- [mm] width (diameter) and height of the shape    
	pos = { x = 100;  y = 100;  z = 0; };      -- [mm] center position	
	-- thickness = 1.0;												   -- [mm] constant wall thickness (do not define if you want to take inside and outside radius from the image)
	min_thickness = 1.0;                       -- [mm] minimal wall thickness (default is 1 shell)
  contour = "marieke.pgm"; -- the image for the shape
	-- texture = "wave.pgm"; -- the image for the surface	
	-- modulation = 1.5;      -- [mm] depth of the surface  modulation (0..255 pixel intensity is 0..modulation mm radius change)
	modulator = function(r,a,z)  return 0.1*z* math.sin(7*a); end;
};

