function normTrace = normalize(trace)
%normalize Squishes each trace to be a real number between 0 and 1
%   First subtracts the minimum value to get the floor. Then divide by the
%   maximum to scale everything down to 1 or below

%%%%%%%%%%%%OLD ONE%%%%%%%%%%%%%%
downshift=min(trace);
trace=trace-downshift;
scalar=max(trace);
normTrace=trace/scalar;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ph4=mean(trace(159:179));%min
% ph6=mean(trace(125:145))-ph4;%max, has to subtract min for maxes to line up
% 
% trace=trace-ph4;
% normTrace=trace/ph6;

end

