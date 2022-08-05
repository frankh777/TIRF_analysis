function [outputTraces, outputBig, outputSmall, steadyStateStart, steadyStateEnd, endOfExp, pH6start, pH6end, pH4start, pH4end] = traceSelection(filename, corrob, noise, shape)
%traceSelection.m gets all traces and then filters based on noise and MAE
%   First, the traces are extracted from the background-subtracted and gaussian intensity corrected movie by tracking each peak
%   over time. The peaks were extracted using the CSOB method from the
%   original movie.  Traces are filtered with manually determined
%   noise and MAE cutoffs. 

%loading data
warning('off','all') % Suppress all the tiff warnings
tstack  = Tiff(filename);
[numRows,numCols] = size(tstack.read()); %image size
movieLength = length(imfinfo(filename)); % movie length
data = zeros(numRows,numCols,movieLength); %new 3D matrix
data(:,:,1)  = tstack.read();
for ii = 2:movieLength
    tstack.nextDirectory()
    data(:,:,ii) = tstack.read();
end
warning('on','all')
data=uint16(data);

bigData=data(:,:,1:movieLength/2);%large signal is first half of movie
smallData=data(:,:,movieLength/2+1:movieLength);%secondary signal is second half

bigPickingImage = zeros(numRows,numCols);
bigBackground = zeros(numRows,numCols);
for ii = 1:10
    bigPickingImage = bigPickingImage + double(bigData(:,:,ii));%average the first 10 frames of data
    bigBackground = bigBackground + double(bigData(:,:,movieLength/2-ii+1));%average the first 10 frames of background 
end
bigPickingImage = uint16(bigPickingImage/10);
bigBackground = uint16(bigBackground/10);

%same thing for secondary signal
smallPickingImage = zeros(numRows,numCols);
smallBackground = zeros(numRows,numCols);
for ii = 1:10
    smallPickingImage=smallPickingImage+double(smallData(:,:,ii));
    smallBackground = smallBackground + double(smallData(:,:,movieLength/2-ii+1));
end
smallPickingImage = uint16(smallPickingImage/10);
smallBackground = uint16(smallBackground/10);

%find peaks and put into peakMaps with the block scanning method, with
%current arugments it is using Coarse-Scanning Outlier Block (CSOB)
bigPeakMap = logical(blockScanner(bigPickingImage, 8, 'median', 4));
smallPeakMap = logical(blockScanner(smallPickingImage, 8, 'median', 4));

%option to corroborate peaks between primary and secondary signals
if(corrob)
    peakMap=double(corrobPeakMaps(bigPeakMap,smallPeakMap));%noise removal
else
    peakMap=double(bigPeakMap);
end

peaksOut = peakPlot(peakMap,bigData(:,:,1));%get all peak locations and intensities
peakSize=size(peaksOut,1);%how many peaks
%subtract background
bigData=uint16(double(bigData)-double(bigBackground));
smallData=uint16(double(smallData)-double(smallBackground));

%get figure of regular image
figure()
imagesc(imadjust(bigData(:,:,1)))
xlabel('X pixel')
ylabel('Y pixel')
title("Original image with contrast")
set(gca,'FontSize',18)
% figure()
% imagesc(bigData(:,:,1))

%correcting movies for intensity
bigData=gaussianCorrection(bigData,bigPickingImage,bigBackground);
smallData=gaussianCorrection(smallData,bigPickingImage,bigBackground);
% figure()
% imagesc(bigData(:,:,1))
%get figure of gaussian corrected image
figure()
imagesc(imadjust(uint16(bigData(:,:,1))))
xlabel('X pixel')
ylabel('Y pixel')
title("Gaussian corrected image with contrast")
set(gca,'FontSize',18)

bigsignal = zeros(movieLength/2,peakSize);
smallsignal = zeros(movieLength/2,peakSize);
for ii = 1:movieLength/2%frame of movie, essentially time
    bigpeaksOut = peakPlot(peakMap,bigData(:,:,ii));
    smallpeaksOut = peakPlot(peakMap,smallData(:,:,ii));
    peakSize=size(bigpeaksOut);
    for jj = 1:peakSize(1)%which peak is looked at, intentsity at each point
        bigsignal(ii,jj) = bigpeaksOut(jj,3);
        smallsignal(ii,jj) = smallpeaksOut(jj,3);
    end
end

ratioSignal=bigsignal./smallsignal;%can comment out if variable already exists
cutoff=.2800;%for noise with newest normalization method

bigGood=[];
bigBad=[];
smallGood=[];
smallBad=[];

%The following chunk of code also automatically finds the entire
%background region. If it becomes useful for future work, lastNonNaN is the
%beginning of the background measurement portion of the movie.

%Get where the background starts based on which parts of the signal are Inf
%or NaN meaning they are dividing by 0, which only happens in background
%measurements
avgRatioSignal=mean(ratioSignal,2);
avgRatioSignal(isinf(avgRatioSignal)) = NaN;%trick to make later selection constant
lastNonNaN = max(find(~isnan(avgRatioSignal)));%index of last normal number

%output figure for identifying sections
figure()
plot(avgRatioSignal)
xlabel('Frame number')
ylabel('Normalized ratio values')
title("Experiment timeseries")
set(gca,'FontSize',18)
drawnow;
%bgStart is no longer needed since background can be easily automatically


disp("" + ...
    "The trace needed for making selections may be behind this window" + ...
    "")
%25,100,120 respectively for provided experiment
steadyStateStart = str2double(input ("In which frame does the steady state start? ", "s"));
steadyStateEnd = str2double(input ("In which frame does the steady state end? ", "s"));
endOfExp = str2double(input ("In which frame does the experiment end (when ionophore is introduced)? ", "s"));
%that is the flat high part after steady state, 125,145 respecitvely for
%testing
pH6start = str2double(input ("In which frame does the pH 6 step start? ", "s"));
pH6end = str2double(input ("In which frame does the pH 6 step end? ", "s"));
%the lowest portion of the calibration curve, 159,179 respectively for
%testing
pH4start = str2double(input ("In which frame does the pH 4 step start? ", "s"));
pH4end = str2double(input ("In which frame does the pH 4 step end? ", "s"));

%%%%%%%%%%%%%%%%NOISE REMOVAL%%%%%%%%%%%%%%%%
%removes noisy traces by sd of frames 25-100 where it is steady-state
if(noise)
    goodTraces=[];
    badTraces=[];
    for ii = 1:peakSize(1)
        trace=slopeNormalize(ratioSignal(1:lastNonNaN,ii), pH6start, pH6end, pH4start, pH4end);%use new norm
        if(std(trace(steadyStateStart:steadyStateEnd))>cutoff)
            badTraces=[badTraces ratioSignal(1:lastNonNaN,ii)];
            bigBad=[bigBad bigsignal(1:lastNonNaN,ii)];
            smallBad=[smallBad smallsignal(1:lastNonNaN,ii)];
        else
            goodTraces=[goodTraces ratioSignal(1:lastNonNaN,ii)];
            bigGood=[bigGood bigsignal(1:lastNonNaN,ii)];
            smallGood=[smallGood smallsignal(1:lastNonNaN,ii)];
        end
    end
else
    goodTraces=ratioSignal;
    bigGood=bigsignal;
    smallGood=smallsignal;
end

%setting params for shape removal (MAE)
avgGood=normalize(mean(goodTraces(1:lastNonNaN,:),2));%stick with old norm
ideal=avgGood(1:endOfExp);
numGood=size(goodTraces);
numGood=numGood(2);
badness=zeros([1 numGood]);

%%%%%%%%%%%%%%WEIRD SHAPE REMOVAL WITH MAE%%%%%%%%%%%%%
if(shape)
    for ii = 1:numGood
        experiment=goodTraces(1:endOfExp,ii);
        badness(ii)=L1norm(ideal,experiment);%still uses old norm because of shortened trace
    end
    
    cutoff=.2000;
    acceptedTraces=[];
    acceptedBig=[];
    acceptedSmall=[];
    
    for ii = 1:numGood
        if(badness(ii)<cutoff)
            acceptedTraces=[acceptedTraces goodTraces(:,ii)];
            acceptedBig=[acceptedBig bigGood(:,ii)];
            acceptedSmall=[acceptedSmall smallGood(:,ii)];
        end
    end
else
    acceptedTraces=goodTraces;
    acceptedBig=bigGood;
    acceptedSmall=smallGood;
end

outputTraces=acceptedTraces';
outputBig=acceptedBig';
outputSmall=acceptedSmall';

end