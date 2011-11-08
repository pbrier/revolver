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
  render = vase.render;  										   -- the type of shape (set to vase.render for a vase)
	material = materials.pla.standard3mm;        -- material (materials.pla.standard3mm)
	style = styles.pla.mediumq;                  -- build style (styles.pla.mediumq)
	size = 	{	width = 30; height = 40; };        -- [mm] width (diameter) and height of the shape    
	pos = { x = 120;  y = 120;  z = 0.2; };      -- [mm] X,Y center position and Z start level
	-- thickness = 1.0;												   -- [mm] constant wall thickness (do not define if you want to take inside and outside radius from the image)
                                             -- when thickness is define, only the "outside" diameter is used from the bitmap file (right black edge) 
	min_thickness = 1.0;                       -- [mm] minimal wall thickness (default is 1 shell) Whem specified, no wall will be made thinner than this thickness, even
                                             -- if the bitmap specifies otherwise
  contour = "square.pgm";  -- the image for the shape use "BINARY PGM" image with white background, and black line that defines the shape
	texture = "hello.pgm";   -- the image for the surface. Use "BINARY PGM" image. BLACK is "0.0" and White is "1.0" modulation of the radius. Use "modulation" parameter to scale this
	modulation = -1;      -- [mm] depth of the surface  modulation for the texture (0..255 pixel intensity is 0..modulation mm radius change)
	-- modulator = function(r,a,z)  return 0.1*z* math.sin(7*a); end; -- Specify a function to modulate the surface
	-- frequency = 3.0;      -- Use default "sine wave" modulation of the radius, with specified frequenty, and "modulation" amplitude
};

