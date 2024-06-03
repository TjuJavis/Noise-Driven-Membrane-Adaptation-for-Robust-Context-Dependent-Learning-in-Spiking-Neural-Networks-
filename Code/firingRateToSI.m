function [SIPlace, SIItem, SIContext] = firingRateToSI(FiringRate, opt)
% firingRateToSI
%   FiringRate  - 激发率矩阵，维度为：
%                 nTrial x nStim x nCell（试次数 x 刺激数 x 神经元数）。
%   opt         - 结构体，包含字段：
%                 * nCell - 神经元数量。
%                 * nStim - 刺激数量。
%                 * nBin  - 用于选择性指数的箱数。
%
% RETURN
%   SIPlace     - 位置的选择性指数。
%   SIItem      - 物品的选择性指数。
%   SIContext   - 上下文的选择性指数。
%
% DESCRIPTION
%   将激发率转换为选择性指数。

%   Florian Raudies, 07/22/2013, Boston University.

nCell   = opt.nCell;
nStim   = opt.nStim;
nBin    = opt.nBin;
nBlock  = 30;

% 计算每个箱内的平均激发率，每个箱有30个试次。
FiringRatePerBin = zeros(nBin, nStim, nCell);
for iBin = 1:nBin
    FiringRatePerBin(iBin, :, :) = mean(FiringRate((iBin-1)*nBlock+(1:nBlock), :, :), 1);
end

% *************************************************************************
% 位置的选择性指数。
% *************************************************************************
n = 4;
LambdaPlace         = zeros(nBin, n, nCell);
LambdaPlace(:, 1, :)  = 0.5 * (FiringRatePerBin(:, 1, :) + FiringRatePerBin(:, 5, :));
LambdaPlace(:, 2, :)  = 0.5 * (FiringRatePerBin(:, 2, :) + FiringRatePerBin(:, 6, :));
LambdaPlace(:, 3, :)  = 0.5 * (FiringRatePerBin(:, 3, :) + FiringRatePerBin(:, 7, :));
LambdaPlace(:, 4, :)  = 0.5 * (FiringRatePerBin(:, 4, :) + FiringRatePerBin(:, 8, :));
LambdaPref          = max(LambdaPlace, [], 2);
SIPlace             = (n - sum(LambdaPlace./(eps ...
                                    + repmat(LambdaPref, [1 n 1])), 2))/(n-1);
SIPlace(LambdaPref==0)  = 0;
SIPlace                 = squeeze(SIPlace);

% *************************************************************************
% 物品的选择性指数。
% *************************************************************************
n = 2;
LambdaItem          = zeros(nBin, n, nCell);
LambdaItem(:, 1, :)   = 0.25 * sum(FiringRatePerBin(:, 1:4, :), 2); % 1, 2, 3, 4
LambdaItem(:, 2, :)   = 0.25 * sum(FiringRatePerBin(:, 5:8, :), 2); % 5, 6, 7, 8
LambdaPref          = max(LambdaItem, [], 2);
SIItem              = (n - sum(LambdaItem./(eps ...
                                    + repmat(LambdaPref, [1 n 1])), 2))/(n-1);
SIItem(LambdaPref==0)   = 0;
SIItem                  = squeeze(SIItem);

% *************************************************************************
% 上下文的选择性指数。
% *************************************************************************
n = 2;
LambdaContext       = zeros(nBin, n, nCell);
LambdaContext(:, 1, :) = 0.25 * sum(FiringRatePerBin(:, 1:2:7, :), 2); % 1, 3, 5, 7
LambdaContext(:, 2, :) = 0.25 * sum(FiringRatePerBin(:, 2:2:8, :), 2); % 2, 4, 6, 8
LambdaPref          = max(LambdaContext, [], 2);
SIContext           = (n - sum(LambdaContext./(eps ...
                                    + repmat(LambdaPref, [1 n 1])), 2))/(n-1);
SIContext(LambdaPref==0) = 0;
SIContext               = squeeze(SIContext);

% firingRateToSI 的目的是将神经元的射频率数据转换为选择性指数（Selectivity Index, SI），
% 用于评估神经元对于位置（place）、项目（item）和上下文（context）的选择性。
