function [value]=WDQFlucEntropy(data)
%WDQFLUCENTROPY calculates fluctuation entropy
% This script is written by Wang Deqing
% Date: September 25, 2015
% Email: deqing.wang@foxmail.com
% Website: http://deqing.me/
% Affiliation: Dalian University of Technology
% Requirement: MIRToolbox 1.6.1

FlucData=abs(data);
summat=repmat(sum(FlucData)+repmat(eps,...
    [1 size(FlucData,2) size(FlucData,3) size(FlucData,4)]),...
    [size(FlucData,1) 1 1 1]);
FlucData=FlucData./summat;
value=-sum(FlucData.*log(FlucData+eps))./log(size(FlucData,1));
end