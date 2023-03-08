% Author: Deqing Wang
% Email: deqing.wang@foxmail.com
% Website: http://deqing.me/
% Affiliation: Dalian University of Technology, China
%              University of Jyväskylä, Finland
% Date: April 22, 2021
% Desctirption: Install toolboxes online.
%
%
%% Install Tensor Toolbox
% Tensor toolbox can be downloaded manually from http://www.tensortoolbox.org/
%
% Reference:
% General software, latest release: Brett W. Bader, Tamara G. Kolda and
% others, Tensor Toolbox for MATLAB, Version 3.2.1,
% www.tensortoolbox.org, April 5, 2021.
%

Tensor_Toolbox_path = [pwd filesep 'tensor_toolbox-v3.2.1'];
if ~exist(Tensor_Toolbox_path,'dir')
    fprintf('Installing Tensor Toolbox ......\n');
    Tensor_Toolbox_url = 'https://gitlab.com/tensors/tensor_toolbox/-/archive/v3.2.1/tensor_toolbox-v3.2.1.zip';
    TensorToolboxFileName = 'tensor_toolbox-v3.2.1.zip';
    TensorToolboxFile=websave(TensorToolboxFileName,Tensor_Toolbox_url);
    unzip(TensorToolboxFileName,pwd);
    addpath(genpath(Tensor_Toolbox_path));
    fprintf('Tensor toolbox has been installed, and the path is \n\n    ''%s''\n\n',...
        Tensor_Toolbox_path);
end

%% Install EEGLAB
% EEGLAB can be downloaded manually from
% https://sccn.ucsd.edu/eeglab/download.php
%
% Reference:
% Delorme, Arnaud, and Scott Makeig. "EEGLAB: an open source toolbox for
% analysis of single-trial EEG dynamics including independent component
% analysis." Journal of neuroscience methods 134.1 (2004): 9-21.
% 

EEGLAB_path = [pwd filesep 'eeglab2021.0'];
if ~exist(EEGLAB_path,'dir')
    fprintf('Installing EEGLAB ......\n');
    EEGLAB_url = 'https://sccn.ucsd.edu/eeglab/currentversion/eeglab_current.zip';
    unzip(EEGLAB_url,pwd);
    addpath(genpath(EEGLAB_path));
    fprintf('The latest EEGLAB has been installed, and the path is \n\n    ''%s''\n\n',...
        EEGLAB_path);
end

%% Install MIR Toolbox 1.6.1
% MIR toolbox can be downloaded manually from
% https://www.jyu.fi/hytk/fi/laitokset/mutku/en/research/materials/mirtoolbox
%
% Reference:
%
% O. Lartillot and P. Toiviainen. A Matlab toolbox for musical feature
% extraction from audio. International conference on digital audio effects.
% Vol. 237. 2007.
%

MIR_Toolbox_path = [pwd filesep 'MIRtoolbox1.6.1'];
if ~exist(MIR_Toolbox_path,'dir')
    fprintf('Installing MIR Toolbox 1.6.1 ......\n');
    MIR_Toolbox_url = 'https://www.jyu.fi/hytk/fi/laitokset/mutku/en/research/materials/mirtoolbox/MIRtoolbox1.6.1';
    MIRToolboxFileName = 'MIRtoolbox1.6.1.zip';
    MIRToolboxFile=websave(MIRToolboxFileName,MIR_Toolbox_url);
    unzip(MIRToolboxFile,pwd);
    addpath(genpath(MIR_Toolbox_path));
    fprintf('MIR toolbox has been installed, and the path is \n\n    ''%s''\n\n',...
        MIR_Toolbox_path);
end

%%
