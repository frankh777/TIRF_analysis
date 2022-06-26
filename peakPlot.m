function peaksOut = peakPlot(peakMap,orgImage)
%peakPlot returns the coordinates and intensities of peaks
%   It takes the peakMap along with the original image. Then it returns the
%  a matrix with the (x,y) coordinates of each peak as well as the
%  intensities. peaksOut = [y x intensity]

numPeaks=sum(peakMap(:) == 1); %determines how big we need to make the output
peaksOut = zeros(numPeaks,3); %[y1 x1 br1; y2 x2 br2; ... ; yn xn brn] br is brightness
% x and y are flipped because MATLAB is indexed by row and column

imsize = size(orgImage); % size of matrix for iteration
counter=1; %counter for placing each peak into proper row of output

inteImage=zeros(imsize(1)+2,imsize(2)+2);
inteImage(2:1+imsize(1), 2:1+imsize(2))=orgImage;

%this iterates through the peaksMap to record the peaks
for i = 1:imsize(1)
    for j = 1:imsize(2)
        if (peakMap(i,j)==1)
            peaksOut(counter,1)=i; %y
            peaksOut(counter,2)=j; %x
            chunk=inteImage(i:i+2,j:j+2);
            peaksOut(counter,3)=sum(sum(chunk)); %gets brightness, could be taken from the copy as well
            counter=counter+1;
        end
    end
end

end

