function C=WDQFlucCentroid(data)
%WDQFLUCCENTROID calculates fluctuation centroid
% This script is written by Wang Deqing
% Date: September 25, 2015
% Email: deqing.wang@foxmail.com
% Website: http://deqing.me/
% Affiliation: Dalian University of Technology
% Requirement: MIRToolbox 1.6.1

flucdata=data;
framenumber=size(flucdata,2);
windowlength=size(flucdata,1);
C=zeros(1,framenumber);
m=((10/(windowlength-1))*(0:windowlength-1))';
for ii=1:framenumber
    flucdataframe=flucdata(:,ii);%/(max(spectrodata(:,ii))+eps);
    C(ii)=sum(m.*flucdataframe)/(sum(flucdataframe)+eps);    
end

end