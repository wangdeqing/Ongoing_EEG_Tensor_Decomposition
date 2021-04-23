% Author: Deqing Wang
% Email: deqing.wang@foxmail.com
% Website: http://deqing.me/
% Affiliation: Dalian University of Technology, China
%              University of Jyväskylä, Finland
% Date: April 22, 2021
% Desctirption: Tensor decomposition of an onging EEG tensor using the
% inexact alternating proximal gradient (iAPG) algorithm.
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

%%
clear
close all

%% Load Tensor Data
load(['Data' filesep 'OngoingEEG_Tensor']);
load(['Data' filesep 'mirLongTermFeatures']);
load(['Data' filesep 'chanlocs64']);

%% Preparation of tensor decomposition
TensorTrue = tensor(OngoingEEG_Tensor); % The third-order tensor
N = ndims(TensorTrue);

% Tensor Decomposition Parameters
R = 30; % The pre-defined number of components

%
ModeSizes = size(TensorTrue);
FR = zeros(N,1); % FR is the ratio of the number of data entries to the degrees of freedom
inv_FR = zeros(N,1);
for ii = 1:N
    FR(ii,1) = prod(ModeSizes) / (R * (ModeSizes(ii) + prod(ModeSizes([1:ii-1 ii+1:end])) - R));
    inv_FR(ii,1) = 1/FR(ii,1);
end
IndicatorDL = nthroot(prod(inv_FR),N); % DL: difficulty level
sIndicatorDL = sprintf('%.3f',IndicatorDL);
fprintf(['ModeSize:\t' mat2str(ModeSizes) '\n' 'RankSize: \t' mat2str(R) '\n']);
fprintf(['DL:\t\t\t' sIndicatorDL '\n']);

% Empirical rule for selecting the number of inner iterations
if IndicatorDL < 0.1
    J = 10;
elseif IndicatorDL >= 0.1
    J = 20;
end
fprintf(['The number of inner iterations is ' mat2str(J) '.\n']);
InnerIter_v = J*ones(N,1);

%% Start of the NCP tensor decomposition using iAPG algorithm
rng('shuffle');
[A,Out] = ncp_iapg(TensorTrue,R,'maxiters',99999,'tol',1e-6,...
    'init','random','printitn',1,'inner_iter',InnerIter_v,...
    'maxtime',1200,'stop',2,'printitn',1);

%%
fprintf('Elapsed time is %4.6f seconds.\n',Out.time(end));
fprintf('Solution relative error = %4.4f\n\n',Out.relerr(2,end));

%%

