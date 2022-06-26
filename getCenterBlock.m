%getBlock.m - a function that returns the 11x11 block surrounding a pixel in a tiff image
%centerPixel is a 1x2 matrix with the x and y coordinate of the pixel of interest
%wholeImage is the matrix of the image
function block = getCenterBlock(centerPixel, wholeImage, padding)
  
  %this sections pads the image with 0s
  %this way there is no error if the center is too close to the edge
  imageDim = size(wholeImage);
  paddedImage = zeros(imageDim+padding*2);
  padDim = size(paddedImage); 
  paddedImage(padding+1:padDim(1,1)-padding, padding+1:padDim(1,2)-padding) = wholeImage; %replacing the center
  
  %get an 2x+1 by 2x+1 block that potentially has 0s
  block = paddedImage(centerPixel(1,1):centerPixel(1,1)+padding*2, centerPixel(1,2):centerPixel(1,2)+padding*2);
  
  %deletes the rows with 0s
  block( ~any(block,2), : ) = [];
  
  %deletes the columns with 0s
  block( :, ~any(block,1) ) = [];
  %it is likely that no rows of 0s will be deleted
  
end
  
  
