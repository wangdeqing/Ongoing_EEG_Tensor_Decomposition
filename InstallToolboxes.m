%%

%% Install Tensor Toolbox
fprintf('Installing Tensor Toolbox ...... \n');
tensor_toolbox_path = [pwd filesep 'tensor_toolbox-v3.2.1'];
unzip('tensor_toolbox-v3.2.1.zip',tensor_toolbox_path);
addpath(genpath(tensor_toolbox_path));
fprintf('Tensor Toolbox has been installed!\n\n');

%% Install MIR Toolbox 1.6.1
fprintf('Installing MIR Toolbox 1.6.1 ...... \n');
mir_toolbox_path = [pwd filesep 'MIRtoolbox1.6.1'];
unzip('MIRtoolbox1.6.1.zip',mir_toolbox_path);
addpath(genpath(mir_toolbox_path));
fprintf('MIR Toolbox 1.6.1 has been installed!\n\n');

%% Install EEGLAB
% eeglab_path = [pwd filesep 'eeglab2021.0'];
% unzip('eeglab2021.0.zip',eeglab_path);
% addpath(genpath(eeglab_path));

%% Install EEGLAB
EEGLAB_path = [pwd filesep 'eeglab'];
if ~exist(EEGLAB_path,'dir')
    % EEGLAB can be downloaded manually from
    % https://sccn.ucsd.edu/eeglab/download.php
    mkdir(EEGLAB_path);
    fprintf('Installing EEGLAB ......\n');
    EEGLAB_url = 'ftp://sccn.ucsd.edu/pub/daily/eeglab2021.0.zip';
    unzip(EEGLAB_url,EEGLAB_path);
    addpath(genpath(EEGLAB_path));
    fprintf('The latest EEGLAB has been downloaded and unzipped to\n\n    ''%s''\n\n',...
        EEGLAB_path);
end

%%
fprintf('All toolboxes have been installed!\n');
