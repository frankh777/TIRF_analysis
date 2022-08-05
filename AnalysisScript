[name,filepath] = uigetfile('*.tif');
[acceptedTraces,bigsignal,smallsignal, steadyStateStart, steadyStateEnd, endOfExp, pH6start, pH6end, pH4start, pH4end]=traceSelection(strcat(filepath,name),false,true,true); %import TIFF file containing microscopy data and select all traces
numsigs=size(acceptedTraces);
numsigs=numsigs(1);


%The following chunk of code is for pH calibration, however, it does not
%work optimally. Fitting with an exponential curve does better than trying
%with a proper pH curve. One workaround for fitting with a log-based
%function is to fit 10^function, and then take the log of the result to
%prevent an error from log(0)


% %Allow for identification of pH calibration steps
% figure()
% plot(mean(acceptedTraces))
% drawnow;
% 
% "The trace needed for making selections may be behind this window"
% %Get pH steps and generate vectors of same length for storing start and
% %endpoints, which are updated one pH step at a time
% pHSteps= str2double(strsplit(input("What are the pH steps in the calibration curve? (seperate with commas) ", "s"),','));
% indpKa= str2double(input("What is the pKa of the fluorescent indicator? ", "s"));
% pHStart = zeros([length(pHSteps),1]);
% pHStop = zeros([length(pHSteps),1]);
% "The program will take an average of the values within each range, please ensure the range is representative of that step"
% for ii=1:length(pHSteps)
%     prompt=strcat("In which frame does the pH ", num2str(pHSteps(ii)) ," step of the pH calibration curve start? ");
%     pHStart(ii)=str2double(input(prompt, "s"));
%     prompt=strcat("In which frame does the pH ", num2str(pHSteps(ii)) ," step of the pH calibration curve end? ");
%     pHStop(ii)=str2double(input(prompt, "s"));
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Testing scatterplot and fitting of concentrations before applying to all
% testTrace = mean(acceptedTraces);
% intensitiesBypH=zeros([length(pHSteps),1]);
% for ii=1:length(pHSteps)
%     intensitiesBypH(ii)=mean(testTrace(pHStart(ii):pHStop(ii)));
% end
% 
% fitfun = fittype('b*log10(intensitiesBypH/(a-intensitiesBypH))','dependent',{'pHSteps'},'independent',{'intensitiesBypH'}, 'coefficients',{'a','b'});
% [fitted_curve,gof] = fit(intensitiesBypH',pHSteps',fitfun,'StartPoint',[1,4.8]);
% 
% figure()
% scatter(intensitiesBypH, pHSteps)
% hold on;
% plot(intensitiesBypH,fitted_curve(intensitiesBypH))
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



slope=zeros(numsigs,1);
intensities=zeros(numsigs,1);

disp("" + ...
    "The trace needed for making selections may be behind this window" + ...
    "")
%16:19
slopeStart = str2double(input ("Where does the slope begin to reach its maximum? ", "s"));
slopeEnd = str2double(input ("When does the slope end its maximum? ", "s"));


for ii=1:numsigs
    intensities(ii)=mean(bigsignal(ii,1:10)); %intensity of a liposome correlates with volume
    normalized=slopeNormalize(acceptedTraces(ii,1:pH4end), pH6start, pH6end, pH4start, pH4end);

    x=slopeStart:slopeEnd;
    instantSlope=normalized(x);
    p=polyfit(x,instantSlope,1);
    slope(ii)=p(1);%collect the instantaneous slopes, which correspond to transport rate
end

slope=nonzeros(slope);
intensities=nonzeros(intensities);

figure()
histogram(intensities)
xlabel('Intensity')
ylabel('Count');
title('Histogram of intensities')
set(gca,'FontSize',18)



normalized=slopeNormalize(acceptedTraces(1,1:pH4end), pH6start, pH6end, pH4start, pH4end);
x=slopeStart:slopeEnd;
instantSlope=normalized(x);
p=polyfit(x,instantSlope,1);
figure()
x=2:2:76;

scatter(x,normalized((1:38)),60, 'filled')
hold on;
x=1:38;
y=x*p(1)+p(2);
x=2:2:76;
plot(x,y)

xlabel('Time (s)')
ylabel('Normalized ratio value');
title("Slope fit on single transporter")
set(gca,'FontSize',18)


avgTrace=slopeNormalize(mean(acceptedTraces), pH6start, pH6end, pH4start, pH4end);
x=16:19;
instantSlope=[avgTrace(16) avgTrace(17) avgTrace(18) avgTrace(19)];%scuffed but itll work, make more elegant later
p=polyfit(x,instantSlope,1);

figure()
x=2:2:76;%changes the scale of the x-axis
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
title("Average experiment slope fit")
set(gca,'FontSize',18)
% slope=zeros(1,5333);


figure()
histogram(slope)
xlabel('Slope')
ylabel('Count');
title('Distribution of slopes')
set(gca,'FontSize',18)


% Fit = polyfit(intensities,slope,1); % x = x data, y = y data, 1 = order of the polynomial i.e a straight line 
% 
figure()
scatter(intensities,slope)
xlabel('Intensity')
ylabel('Slope');
title('Scatterplot of slope and intensities')
set(gca,'FontSize',18)

%set(gca,'xscale','log')
%set(gca,'yscale','log')

%relative flux (∆molecules) = slope(∆concentration) * intensities (volume)
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
title('Distribution of relative flux')
set(gca,'FontSize',18)
 