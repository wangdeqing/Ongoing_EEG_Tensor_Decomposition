function [P,Out] = ncp_iapg(X,R,varargin)
%NCP_IAPG: Nonnegative CANDECOMP/PARAFAC tensor decomposition using
% inexact alternating proximal gradient (iAPG) algorithm in block
% coordinate descent framework.
%
% min 0.5*||M - A_1\circ...\circ A_N||_F^2 + r(A)
% subject to A_1>=0, ..., A_N>=0
%
% input: 
%       X: input nonnegative tensor
%       R: estimated rank (each A_i has r columns); require exact or moderate overestimates
%       varargin.
%           'tol' - tolerance for relative change of function value, default: 1e-4
%           'maxiters' - max number of iterations, default: 500
%           'maxtime' - max running time, default: 1000
%           'dimorder' - Order to loop through dimensions {1:ndims(A)}
%           'init' - Initial guess [{'random'}|'nvecs'|cell array]
%           'printitn' - Print fit every n iterations; 0 for no printing {1}
%           'inner_iter' - A vector of the number of inner iterations of
%           each subproblem, default: 20*ones(Number of dimension,1)
%           'stop' - Stopping condition. 0 for stopping by maxtime or
%           maxiters; 1 for change of objective function; 2 for change of
%           data fitting. Default: 2
%           'regparams' - parameters of Frobenius regularization and
%           sparse regularization.
% output:
%       P: nonnegative ktensor
%       Out.
%           iter: number of iterations
%           time: running time at each iteration
%           obj: history of objective values
%           relerr: history of relative objective changes (row 1) and relative residuals (row 2)
%
% This script requires MATLAB Tensor Toolbox from
% http://www.sandia.gov/~tgkolda/TensorToolbox/
%
% Author: Deqing Wang
% Email: deqing.wang@foxmail.com
% Website: http://deqing.me/
% Affiliation: Dalian University of Technology, China
%              University of Jyväskylä, Finland
% Date: October 15, 2019
%
% Citation Information:
% D. Wang and F. Cong, An inexact alternating proximal gradient algorithm
% for nonnegative CP tensor decomposition,
% Science China Technological Sciences, 2021. Accepted.
%

%% Extract number of dimensions and norm of X.
N = ndims(X);
normX = norm(X);

%% Set algorithm parameters from input or by using defaults
params = inputParser;
params.addParameter('tol',1e-4,@isscalar);
params.addParameter('maxiters',500,@(x) isscalar(x) & x > 0);
params.addParameter('maxtime', 1000,@(x) isscalar(x) & x > 0);
params.addParameter('dimorder',1:N,@(x) isequal(sort(x),1:N));
params.addParameter('init', 'random', @(x) (iscell(x) || ismember(x,{'random','nvecs'})));
params.addParameter('regparams',zeros(N,2),@(x) (ismatrix(x) || sum(any(x<0))==0));
params.addParameter('inner_iter', 20*ones(N,1), @(x) (isvector(x) & all(x > 0)==1));
params.addParameter('stop', 2, @(x) (isscalar(x) & ismember(x,[0,1,2])));
params.addParameter('printitn',1,@isscalar);
params.parse(varargin{:});

%% Copy from params object
tol = params.Results.tol;
maxiters = params.Results.maxiters;
maxtime = params.Results.maxtime;
dimorder = params.Results.dimorder;
init = params.Results.init;
regparams = params.Results.regparams;
inner_iter = params.Results.inner_iter;
stop = params.Results.stop;
printitn = params.Results.printitn;

%% Error checking 
% Error checking on maxiters
if maxiters < 0
    error('OPTS.maxiters must be positive');
end

% Error checking on dimorder
if ~isequal(1:N,sort(dimorder))
    error('OPTS.dimorder must include all elements from 1 to ndims(X)');
end

%% Set up and error checking on initial guess for U.
if iscell(init)
    Uinit = init;
    if numel(Uinit) ~= N
        error('OPTS.init does not have %d cells',N);
    end
    for n = dimorder(1:end)
        if ~isequal(size(Uinit{n}),[size(X,n) R])
            error('OPTS.init{%d} is the wrong size',n);
        end
    end
else
    if strcmp(init,'random')
        Uinit = cell(N,1);
        for n = dimorder(1:end)
            Uinit{n} = max(0,randn(size(X,n),R)); % randomly generate each factor
        end
    elseif strcmp(init,'nvecs') || strcmp(init,'eigs') 
        Uinit = cell(N,1);
        for n = dimorder(1:end)
            k = min(R,size(X,n)-2);
            fprintf('  Computing %d leading e-vectors for factor %d.\n',k,n);
            Uinit{n} = abs(nvecs(X,n,k));
            if (k < R)
              Uinit{n} = [Uinit{n} rand(size(X,n),R-k)]; 
            end
        end
    else
        error('The selected initialization method is not supported');
    end
end

%% Set up for iterations - initializing U and the fit.
U = Uinit;
fit0 = 0;

% Initial object value
obj0=0.5*normX^2;

% Normalize factors
Xnormpower=normX^(1/N);
for n = dimorder(1:end)
    U{n}=U{n}/norm(U{n},'fro')*Xnormpower;
end

U0=U;
Um=U;

% Tolerance
tolU = 1e-12*ones(N,1);

nstall = 0;
t0 = ones(N,1); t = ones(N,1); % used for extrapolation weight update

%% Main Loop: Iterate until convergence
start_time = tic;
if printitn>=0
    fprintf('\nNCP tensor decomposition using iAPG algorithm:\n');
end
if printitn==0, fprintf('Iteration:      '); end
for iter = 1:maxiters
    if printitn==0, fprintf('\b\b\b\b\b\b%5i\n',iter); end

    iterU0=zeros(N,1);
    % Iterate over all N modes of the tensor
    for n = dimorder(1:end)

        % Compute the matrix of coefficients for linear system
        BtB = ones(R,R);
        for i = [1:n-1,n+1:N]
            BtB = BtB .* (U{i}'*U{i});
        end
        
        % Calculate Unew = X_(n) * khatrirao(all U except n, 'r').
        MTTKRP = mttkrp(X,U,n);
        
        % Solver of the subproblem
        [Unew,Umnew,tnew,~,iterU] = solver_apg(MTTKRP',BtB',U0{n}',Um{n}',...
            t0(n),'tol',tolU(n),'beta',regparams(n,2),'maxiters',inner_iter(n));
        
        iterU0(n)=iterU;
        U{n} = Unew';
        Um{n} = Umnew';
        t(n) = tnew;
    end
    
    % --- diagnostics, reporting, stopping checks ---
    % Initial objective function value
    obj = 0.5*( normX^2 - 2 * sum(sum(U{n}.*MTTKRP)) +...
        sum(sum((U{n}'*U{n}).*BtB)));    
    % After above step, normresidual equals to 
    % 0.5*( normX^2 - 2 * innerprod(X,P) + norm(P)^2 ), where P = ktensor(U).
    
    % Norm of residual value.
    normresidual = sqrt(2*obj);
    % After above step, normresidual equals to
    % sqrt( normX^2 + norm(P)^2 - 2 * innerprod(X,P) ), where P = ktensor(U).
    
    % Objective function value
    for n = dimorder(1:end)
        if regparams(n,2)>0 % L1-norm sparse regularization
            obj = obj + regparams(n,2) * sum(abs(U{n}(:)));
        end
    end
    
    % Compute performance evaluation values
    relerr1 = abs(obj-obj0)/(obj0+1); % relative objective change
    relerr2 = (normresidual / normX); % relative residual
    fit = 1 - relerr2; %fraction explained by model
    fitchange = abs(fit0 - fit);
    current_time=toc(start_time);
    
    % Record performance evaluation values
    Out.obj(iter) = obj;
    Out.relerr(1,iter) = relerr1;
    Out.relerr(2,iter) = relerr2;
    Out.time(iter) = current_time;
    
    % Display performance evaluation values
    if printitn>0
        if mod(iter,printitn)==0
            printout1 = sprintf(' Iter %2d: fit = %e fitdelta = %7.1e, inner iter: ',...
                iter, fit, fitchange);
            printout2 = mat2str(iterU0);
            fprintf([printout1 printout2(2:end-1) '\n']);
        end
    end
    
    % Check stopping criterion
    if stop == 1
        crit = (relerr1<tol);
    elseif stop == 2
        crit = (fitchange < tol);
    else
        crit = 0;
    end
    if crit; nstall = nstall+1; else, nstall = 0; end
    if (nstall >= 3 || relerr2 < tol) && stop == 1; break; end
    if iter > 1 && nstall >= 3 && stop == 2; break; end
    if current_time > maxtime; break; end
    
    if obj>=obj0 
       % restore previous U to make the objective nonincreasing
       Um = U0;
    else
        U0 = U; t0 = t; 
        obj0 = obj;
        fit0 = fit;
    end
end

%% Clean up final result
P = ktensor(U);

if printitn>0
  fprintf(' Final fit = %e \n', fit);
end

Out.iter=iter;

return;

