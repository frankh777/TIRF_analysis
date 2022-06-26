 %analyzeTraces.m - get pH of steady state
acceptedTraces=traceSelection('1_ecCLC_Val_FCCP_Cal.tif',false,true,true);
%acceptedTraces=traceFiltering(gt.fret,true,false);
goodTs = size(acceptedTraces);
numGood = goodTs(1);
pHs=zeros([1 numGood]);
for ii=1:numGood
    steadyRange = mean(double(acceptedTraces(ii,100:119)));
    pH4 = mean(double(acceptedTraces(ii,155:174))); %[oh-]=1e-4
    pH6 = mean(double(acceptedTraces(ii,125:144))); %[oh-]=1e-6
    pHs(ii)=((steadyRange-pH4)/(pH6-pH4))*2+4;
end

figure()
histogram(pHs)
%set(gca,'YScale','log')
title('pH distribution')
% 
% figure()
% plot(avgGood)

% figure()
% plot(acceptedTraces(:,167))
% title('weird one')
% 
% figure()
% plot(acceptedTraces(:,150))
% hold on;
% plot(runningAvg(acceptedTraces(:,150),4))
% hold on;
% plot(runningAvg(acceptedTraces(:,150),8))
% title('normal?')
% 
% figure()
% plot(diff(runningAvg(acceptedTraces(:,150),4)))
% hold on;
% plot(diff(runningAvg(acceptedTraces(:,150),8)))
% title('difss')