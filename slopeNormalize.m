function normalizedTrace = slopeNormalize(trace,pH6start,pH6end,pH4start,pH4end)
%slopeNormalize Normalizes traces for slope analysis using ph6 as max and
%ph4 as min. Values can be above 1
%   Detailed explanation goes here
ph4=mean(trace(pH4start:pH4end));%min
ph6=mean(trace(pH6start:pH6end))-ph4;%max, has to subtract min for maxes to line up

trace=trace-ph4;
normalizedTrace=trace/ph6;
end