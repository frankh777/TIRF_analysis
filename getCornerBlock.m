%getBlock.m - a function that returns the 11x11 block surrounding a pixel in a tiff image
%centerPixel is a 1x2 matrix with the x and y coordinate of the pixel of interest
%wholeImage is the matrix of the image
function block = getCornerBlock(cornerPixel, wholeImage, size)
  
  %get an 2x+1 by 2x+1 block
  block = wholeImage(cornerPixel(1,1):cornerPixel(1,1)+size-1, cornerPixel(1,2):cornerPixel(1,2)+size-1);
  
end
  
  
