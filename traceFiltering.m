function outputTraces = traceFiltering(traces,noise,shape)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

ratioSignal=traces';
peakSize=size(ratioSignal);
cutoff=.0650;
%%%%%%%%%%%%%%%%NOISE REMOVAL%%%%%%%%%%%%%%%%
%removeNoisy.m removes noisy traces by sd of frames 25-100
if(noise)
    goodTraces=[];
    badTraces=[];
    for ii = 1:peakSize(1)
        trace=normalize(ratioSignal(1:320,ii));
        std(trace(25:100))
    if(std(trace(25:100))>cutoff)
        badTraces=[badTraces ratioSignal(1:320,ii)];
    else
        goodTraces=[goodTraces ratioSignal(1:320,ii)];
    end
end
else
    goodTraces=ratioSignal;
end

%setting params for shape removal
avgGood=normalize(mean(goodTraces(1:320,:),2));
ideal=avgGood(1:120);
numGood=size(goodTraces);
numGood=numGood(2);
badness=zeros([1 numGood]);
size(badness)

%%%%%%%%%%%%%%WEIRD SHAPE REMOVAL%%%%%%%%%%%%%
if(shape)
    for ii = 1:numGood
        experiment=goodTraces(1:120,ii);
        badness(ii)=L1norm(ideal,experiment);
    end
    
    cutoff=.1800;
    acceptedTraces=[];
    
    for ii = 1:numGood
        if(badness(ii)<cutoff)
            acceptedTraces=[acceptedTraces goodTraces(:,ii)];
        end
    end
else
    acceptedTraces=goodTraces;
end

outputTraces=acceptedTraces';

end