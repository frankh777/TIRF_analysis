function [outputTraces, outputBig, outputSmall] = traceSelection(filename, corrob, noise, shape)
%traceSelection.m gets all traces and then filters based on noise and MAE
%   First, the traces are extracted from the background-subtracted and gaussian intensity corrected movie by tracking each peak
%   over time. The peaks were extracted using the CSOB method from the
%   original movie.  Traces are filtered with experimentally determined
%   noise and MAE cutoffs. 

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


ratioSignal=bigsignal./smallsignal;%comment out if variable already exists
cutoff=.2800;%for noise with newest norm method
%cutoff=.065;%for older norm method

bigGood=[];
bigBad=[];
smallGood=[];
smallBad=[];
%%%%%%%%%%%%%%%%NOISE REMOVAL%%%%%%%%%%%%%%%%
%removeNoisy.m removes noisy traces by sd of frames 25-100 where it is
%steady-state
%no longer a standalone function but maybe I should make it one
%Also make sure to add customization - or auto-steady state detection
if(noise)
    goodTraces=[];
    badTraces=[];
    for ii = 1:peakSize(1)
        trace=slopeNormalize(ratioSignal(1:320,ii));%use new norm
        %trace=normalize(ratioSignal(1:320,ii));%with old one
        if(std(trace(25:100))>cutoff)
            badTraces=[badTraces ratioSignal(1:320,ii)];
            bigBad=[bigBad bigsignal(1:320,ii)];
            smallBad=[smallBad smallsignal(1:320,ii)];
        else
            goodTraces=[goodTraces ratioSignal(1:320,ii)];
            bigGood=[bigGood bigsignal(1:320,ii)];
            smallGood=[smallGood smallsignal(1:320,ii)];
        end
    end
else
    goodTraces=ratioSignal;
    bigGood=bigsignal;
    smallGood=smallsignal;
end

%setting params for shape removal (MAE)
avgGood=normalize(mean(goodTraces(1:320,:),2));%stick with old norm
ideal=avgGood(1:120);
numGood=size(goodTraces);
numGood=numGood(2);
badness=zeros([1 numGood]);

%%%%%%%%%%%%%%WEIRD SHAPE REMOVAL%%%%%%%%%%%%%
%again might want to make a seperate function for github purposes
if(shape)
    for ii = 1:numGood
        experiment=goodTraces(1:120,ii);
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