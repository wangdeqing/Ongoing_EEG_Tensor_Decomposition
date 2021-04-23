% This script extracts 5 long term music features.
% This script is written by Wang Deqing
% Date: September 25, 2015
% Email: deqing.wang@foxmail.com
% Website: http://deqing.me/
% Affiliation: Dalian University of Technology
% Requirement: MIRToolbox 1.6.1

% Reference:
% V. Alluri, P. Toiviainen, I. P. J‰‰skel‰inen, et al. Large-scale brain
% networks emerge from dynamic processing of musical timbre, key and
% rhythm[J]. Neuroimage, 2012, 59(4): 3677-3689.
%
% O. Lartillot and P. Toiviainen. A Matlab toolbox for musical feature
% extraction from audio. International conference on digital audio effects.
% Vol. 237. 2007.
%
%
%
%% Please install MIR Toolbox 1.6.1 before running this script
%
% MIR Toolbox 1.6.1
% https://www.jyu.fi/hytk/fi/laitokset/mutku/en/research/materials/mirtoolbox
%
%

%% Read audio file
%
% An audio file of 60 seconds. This is used for test on a normal computer.
mirfile=miraudio('60s.wav');
%
% An audio file of 8.5 minutes. A compute with large memory is required.
% mirfile=miraudio('Piazzolla.mp3'); 
%
%%
% Frame
mirfileframe=mirframe(mirfile,'Length',3,'s','Hop',1/3,'/1');
mirframedata=mirgetdata(mirfileframe);
framenumber=size(mirframedata,2);
%%
FluctuationCentroid=zeros(framenumber,1);
FluctuationEntropy=zeros(framenumber,1);
PulseClarity=zeros(framenumber,1);
%%
for ii=0:framenumber-1 % number of frames
    excerpt0=miraudio(mirfile,'Extract',ii,ii+3);
    excerpt=mirframe(excerpt0,'Length',3,'s','Hop',1/3,'/1');
    fluc=(mirfluctuation(excerpt,'summary'));
    flucdata=mirgetdata(fluc);
    FluctuationCentroid(ii+1)=WDQFlucCentroid(flucdata);
    FluctuationEntropy(ii+1)=WDQFlucEntropy(flucdata);
    PulseClarity(ii+1)=mirgetdata(mirpulseclarity(excerpt));
end     

%%
% Tonal Features
mirchr=mirchromagram(mirfile,'Frame',3, 1/3,'Wrap',0,'Pitch',0);
[~, mirtonalkeyclarity] = mirkey(mirchr,'Total',1);
mirtonalmode = mirmode(mirchr);
mirkeyclaritydata=mirgetdata(mirtonalkeyclarity)';
mirmodedata=mirgetdata(mirtonalmode)';

%%
figure;plot(1:framenumber,mirkeyclaritydata);xlabel('Frame Number');ylabel('Value');title('Tonal Key Clarity');
figure;plot(1:framenumber,mirmodedata);xlabel('Frame Number');ylabel('Value');title('Tonal Mode');
figure;plot(1:framenumber,FluctuationCentroid);xlabel('Frame Number');ylabel('Value');title('Fluctuation Centroid');
figure;plot(1:framenumber,FluctuationEntropy);xlabel('Frame Number');ylabel('Value');title('Fluctuation Entropy');
figure;plot(1:framenumber,PulseClarity);xlabel('Frame Number');ylabel('Value');title('Pulse Clarity');

%%
long_term_features = [PulseClarity FluctuationEntropy FluctuationCentroid mirmodedata mirkeyclaritydata];
music_feature_names={'Pulse Clarity','Fluctuation Entropy','Fluctuation Centroid','Mode','Key'};
save mirLongTermFeatures.mat long_term_features music_feature_names

