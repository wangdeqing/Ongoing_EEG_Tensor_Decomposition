function [ H, Hm, t, Gh, iter ] = solver_apg(WtV, WtW, H0, Hm, t0, varargin)
%SOLVER_APG alternating proximal gradient
%   minimize (1/2)*|| V - W*H ||^2 + r(H),
%   s.t. H >= 0.
%
% Author: Deqing Wang
% Email: deqing.wang@foxmail.com
% Website: http://deqing.me/
% Affiliation: Dalian University of Technology, China
%              University of Jyväskylä, Finland
% Date: July 18, 2019
%
% Citation Information:
% D. Wang and F. Cong, An inexact alternating proximal gradient algorithm
% for nonnegative CP tensor decomposition,
% Science China Technological Sciences, 2021. Accepted.
%

%% Set algorithm parameters from input or by using defaults
params = inputParser;
params.addParameter('maxiters',5, @(x) isscalar(x) & x > 0);
params.addParameter('beta',0, @(x) isscalar(x) & x >= 0);
params.addParameter('tol',1e-2, @isscalar);
params.parse(varargin{:});

%% Copy from params object
maxiters = params.Results.maxiters;
beta = params.Results.beta;
tol = params.Results.tol;

%%
Lh = norm(WtW);  % Lipschitz bound for H
beta_to_Lh = beta/Lh;

for iter = 1:maxiters

    % Gradient of H
    Gh = WtW*Hm - WtV; % gradient at H=Hm
        
    % Update H
    H = max(0, Hm - Gh/Lh - beta_to_Lh);% Proximal operator
    
    Rh = H - H0;
    
    % extrapolation
    t = (1+sqrt(1+4*t0^2))/2;
    w = (t0-1)/t; % extrapolation weight
    Hm = H + w*Rh; % extrapolation
    H0 = H; t0 = t;
    
    if norm(Rh(:)) < tol*norm(H(:))
        break
    end
    
end
end
