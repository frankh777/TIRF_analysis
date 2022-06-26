function [cleanedImage, badPeaks] = removeClosePeaks(peakMap,dist)
%removeClosePeaks removes peaks that are within dist pixels of each other
%   Takes chunks of the image that are dist x dist, if there are multiple peaks in
%   that region, they get flagged for removal by being placed into a matrix
%   with the same dimensions of the original image. In the end, the
%   badPeaks map is subtracted from the peakMap to give the cleanedImage
%   with badPeaks removed.

imsize=size(peakMap); % size of peakMap

badPeaks = zeros(imsize); % generate map that's the same size as the peakMap

%iterate through different chunks
for i = 1:imsize(1)-(dist-1)
    for j = 1:imsize(2)-(dist-1)
        chunk = peakMap(i:i+(dist-1),j:j+(dist-1)); %chunk
        if (sum(sum(chunk))>1) %if the chunk has multiple peaks, add them all to the bad map
            for g = i:i+(dist-1)
                for h = j:j+(dist-1)
                    if (peakMap(g,h)==1)
                        badPeaks(g,h) = 1;
                    end
                end
            end
        end
    end
end

cleanedImage = double(peakMap) - badPeaks;

end

