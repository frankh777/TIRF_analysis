function correctedMovie = gaussianCorrection(entireMovie, bigPickingImage, bigBackground)
%gaussianCorrection Corrects big and small images with a gaussian
%   Fits a gaussian to the background subtracted picking image and then
%   corrects the entire movie frame by frame

%entire movie is from one wavelength, big and small are seperate

%meshgrid setup
imsize=size(bigPickingImage);
[xx,yy]=meshgrid(1:imsize(1),1:imsize(2));
XX=1:imsize(1);
YY=1:imsize(2);

%background subtraction
bob=double(bigPickingImage-bigBackground)';

%fitting gaussian
param = gaussfitn([xx(:),yy(:)], [bob(:)]);

%extracting output gaussian
mu=cell2mat(param(3))';
sigma=cell2mat(param(4));
f=mvnpdf([xx(:) yy(:)], mu, sigma);
f=reshape(f,length(YY),length(XX))';

%normalizing gaussian so max is 1
g=f./(max(max(f)));

%setting up corrected movie
movsize=size(entireMovie);
correctedMovie=zeros(movsize);

for ii=1:movsize(3)
    correctedMovie(:,:,ii)=double(entireMovie(:,:,ii))./g;
end

end