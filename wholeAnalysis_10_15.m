[acceptedTraces,bigsignal,smallsignal]=traceSelection('1_ecCLC_Val_FCCP_Cal.tif',false,true,true); %import TIFF file containing microscopy data and select all traces
numsigs=size(acceptedTraces);%
numsigs=numsigs(1);

% normalized=acceptedTraces(4,:);
% figure()
% plot(normalized)
% normalized=acceptedTraces(40,:);
% figure()
% plot(normalized)
% normalized=acceptedTraces(400,:);
% figure()
% plot(normalized)

slope=zeros(numsigs,1);
intensities=zeros(numsigs,1);

for ii=1:numsigs
%     if(mean(bigsignal(ii,1:5))>10000 & mean(bigsignal(ii,1:5))<20000)
%         intensities(ii)=bigsignal(ii,1);
%         normalized=slopeNormalize(acceptedTraces(ii,1:179));
%         slope(ii)=(normalized(24)-normalized(16))/8;
%     end
    intensities(ii)=mean(bigsignal(ii,1:10));
    normalized=slopeNormalize(acceptedTraces(ii,1:179));
    %normalized=acceptedTraces(ii,:);
    %normalized=normalize(bigsignal(ii,:));
    x=16:19;
    instantSlope=[normalized(16) normalized(17) normalized(18) normalized(19)];%scuffed but itll work, make more elegant later
    p=polyfit(x,instantSlope,1);
    slope(ii)=p(1);
%     x=(1:20)';
%     y=normalized(116:135)';
%     expfit=fit(x,y,'exp1');
%     slope(ii)=expfit.a;
end
% figure()
% plot(expfit,x,y)

slope=nonzeros(slope);
intensities=nonzeros(intensities);

figure()
histogram(intensities)
xlabel('Intensity')
ylabel('Count');
set(gca,'FontSize',18)
%title('intensities')


normalized=slopeNormalize(acceptedTraces(1,1:179));
x=16:19;
instantSlope=[normalized(16) normalized(17) normalized(18) normalized(19)];%scuffed but itll work, make more elegant later
p=polyfit(x,instantSlope,1);
figure()
x=2:2:76;
% ratios=(bigsignal./smallsignal)';
% plot(mean(ratios))
scatter(x,normalized((1:38)),60, 'filled')
hold on;
x=1:38;
y=x*p(1)+p(2);
x=2:2:76;
plot(x,y)

xlabel('Time (s)')
ylabel('Normalized ratio value');
set(gca,'FontSize',18)


avgTrace=slopeNormalize(mean(acceptedTraces));
x=16:19;
instantSlope=[avgTrace(16) avgTrace(17) avgTrace(18) avgTrace(19)];%scuffed but itll work, make more elegant later
p=polyfit(x,instantSlope,1);
figure()
x=2:2:76;
% ratios=(bigsignal./smallsignal)';
% plot(mean(ratios))
scatter(x,avgTrace((1:38)),60, 'filled')
hold on;
x=1:38;
y=x*p(1)+p(2);
x=2:2:76;
plot(x,y)
% ratios=(bigsignal./smallsignal)';
% plot(mean(ratios))
%plot(x,mean(acceptedTraces))

xlabel('Time (s)')
ylabel('Normalized ratio value');
set(gca,'FontSize',18)
% slope=zeros(1,5333);


figure()
histogram(slope)
xlabel('Slope')
ylabel('Count');
set(gca,'FontSize',18)
%title('3 frame slope')


slopevint=slope./intensities;
figure()
histogram(slopevint)
title('slope over intensity')

intvslope=intensities./slope;
figure()
histogram(intvslope)
title('intesity over slope')

% Fit = polyfit(intensities,slope,1); % x = x data, y = y data, 1 = order of the polynomial i.e a straight line 
% 
figure()
scatter(intensities,slope)
xlabel('Intensity')
ylabel('Slope');
set(gca,'FontSize',18)
%set(gca,'xscale','log')
%set(gca,'yscale','log')
%title('scatter of slope and intensities')

intxslope=slope.*intensities;
countofBad=0;
for ii =1:length(intxslope)
    if (intxslope(ii)<=-7000)
        countofBad=countofBad+1;
    end
end

figure()
histogram(intxslope, 'BinWidth', 1000)
xlabel('Relative flux')
ylabel('Count');
set(gca,'FontSize',18)
 
%title('slope x intensity distribution')