% Author: Deqing Wang
% Email: deqing.wang@foxmail.com
% Website: http://deqing.me/
% Affiliation: Dalian University of Technology, China
%              University of Jyväskylä, Finland
% Date: April 22, 2021
% Desctirption: Plot ongoing EEG components extracted by NCP using iAPG
% algorithm.
%
%
% Citation Information:
% D. Wang and F. Cong, An inexact alternating proximal gradient algorithm
% for nonnegative CP tensor decomposition,
% Science China Technological Sciences, 2021. Accepted.
%
%
%% Please install the following toolboxes before running this example
%
% Tensor Toolbox
% http://www.tensortoolbox.org/
%
% EEGLAB
% https://sccn.ucsd.edu/eeglab/download.php
%

close all

%% Image folder
CompImgPath=fullfile(pwd,'ResultImage');
if ~exist(CompImgPath,'dir'), mkdir(CompImgPath); end

%%
SpatialFactor = A.U{1};
SpectralFactor = A.U{2};
TemporalFactor = A.U{3};
FreqLow = 1;
FreqHigh = 30;
FreqIndex = linspace(FreqLow,FreqHigh,size(SpectralFactor,1));

%% Correlation Analysis
fprintf('Correlation analysis between temporal and music features ... \n');
Time_zscore=zscore(TemporalFactor);
Features_zscore=zscore(long_term_features);
[p05, p01, p001]=f_p_threshold_oneDim(Time_zscore,Features_zscore);
CORR1=corr(Time_zscore,Features_zscore);

CORR1_P=(CORR1>repmat(p05,size(CORR1,1),1));

%% Plot figures
CompIndex = 0;
for jj=1:size(CORR1_P,2)
    for ii=1:size(CORR1_P,1)
        if CORR1_P(ii,jj)==1
            CompIndex = CompIndex + 1;
            
            figure;
            % Figure
            set(gcf,'outerposition',get(0,'screensize'))
            % Topograph
            subplot(3,4,[1 2 5 6])
            topoplot(zscore(SpatialFactor(:,ii)),chanlocs64);
            colorbar
            title(['Topograph#' int2str(ii)],'fontsize',16);
            % Waveform
            subplot(3,4,[9 10 11 12]);
            plot(zscore(TemporalFactor(:,ii)),'linewidth',2);
            hold on
            plot(zscore(long_term_features(:,jj)),'linewidth',2);
            hold off
            grid on
            xlim([0 length(TemporalFactor(:,ii))]);
            xlabel('Time Points/n','fontsize',14);
            ylabel('Amplitude','fontsize',14);
            title(['Waveform, ' 'Threshold=' num2str(p05(jj))  ', CC=' num2str(CORR1(ii,jj))],'fontsize',16);
            sLegend1=sprintf('Temporal Component #%d',ii);
            legend(sLegend1,music_feature_names{jj},'Location','best');
            % Spectrum
            subplot(3,4,[3 4 7 8])
            plot(FreqIndex,SpectralFactor(:,ii),'linewidth',2);grid on;
            xlim([FreqLow FreqHigh]);
            xlabel('Frequency/Hz','fontsize',14);
            ylabel('Amplitude','fontsize',14);
            title('Spectrum','fontsize',16);
            colormap(jet);
            
            % Save Image
            sCompIndex=sprintf('%02d',CompIndex);
            saveas(gca,[CompImgPath filesep sCompIndex '.png'],'png');
        end        
    end
end


