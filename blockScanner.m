function peakMap = blockScanner(inputImage, blockSize, outMeth, incr)
%blockScanner.m - Block scanning method of finding peaks
%   First corrects image for unevenness, then takes a block to scan across with predetermined increment to find outliers (In function form so it's compatible with evaluation algorithm.

orgImage=inputImage;
imsize=size(orgImage);
orgImage=[orgImage; zeros(1,imsize(2))];%correcting for uneven image dimensions
imsize=size(orgImage);
imout=zeros(imsize);

for i=1:incr:imsize(1)-blockSize+1
    for j=1:incr:imsize(2)-blockSize+1
        block = getCornerBlock([i j],orgImage,blockSize);
        outliers = isoutlier(double(block(:)),outMeth); %getting unrolled map of outliers
        cutoff = median(block);
        chsize=size(block); %variable included so it's easier to change padding
        outliers=reshape(outliers, chsize); %reshaping outlier list into matrix
        %iterates through every element in the block
        for g=1:chsize(1)
            for h=1:chsize(2)
                if (outliers(g,h)==1 & block(g,h)>cutoff)
                    imout((i-1)+g,(j-1)+h) = block(g,h);% only updates outliers above local cutoff, the rest are 0
                end
            end
        end
        
    end
end 

imout=imout(1:511,1:512);
orgImage=orgImage(1:511,1:512);
posPeakMap = imregionalmax(orgImage);
outPeakMap = imregionalmax(imout); %then find the peaks
peakMap = posPeakMap & outPeakMap; %where outliers and regional maxima overlap should be peaks

[peakMap,badMap] = removeClosePeaks(peakMap,3);%badMap

% peaksOut = peakPlot(peakMap,orgImage);
% badOut = peakPlot(badMap,orgImage);
% 
% figure()
% %plotting the modified image after having close pixels removed, with
% %peaks marked
% imagesc(imadjust(orgImage));
% hold on;
% plot(peaksOut(:,2),peaksOut(:,1), 'wo'); %plot all the peaks
% %hold on;
% %plot(badOut(:,2),badOut(:,1),'wo'); %plot the close peaks
% title('Outlier peaks: after close peak cleanup')

end

