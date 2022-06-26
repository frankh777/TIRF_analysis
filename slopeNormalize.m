function normalizedTrace = slopeNormalize(trace)
%slopeNormalize Normalizes traces for slope analysis using ph6 as max and
%ph4 as min. Values can be above 1
%   Detailed explanation goes here
ph4=mean(trace(159:179));%min
ph6=mean(trace(125:145))-ph4;%max, has to subtract min for maxes to line up

trace=trace-ph4;
normalizedTrace=trace/ph6;
end