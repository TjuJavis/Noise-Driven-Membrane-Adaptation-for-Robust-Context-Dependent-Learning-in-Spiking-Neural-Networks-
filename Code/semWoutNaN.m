function D = semWoutNaN(D, dim)
% semWoutNaN
%   D   - N维数据矩阵。
%   dim - 用于计算均值的维度。
%
% RETURN
%   D   - (N-1)维数据矩阵。在Matlab中，维度dim被保留并设置为1。
%
% DESCRIPTION
%   计算沿维度dim的D的均值的标准误差（SEM），不包括NaN条目。

%   Florian Raudies, 09/07/2014, Boston University.

Dim         = ones(1, length(size(D)));
Dim(dim)    = size(D, dim);
Index       = isnan(D);
D(Index)    = 0;

% 该维度中的元素数量。
N  = size(D, dim) - sum(Index, dim);
% 该维度上的均值。
M = sum(D, dim)./(eps + N);
% 均值的标准误差。
D = sqrt(sum((~Index).*(D - repmat(M, Dim)).^2, dim))./(eps + N);
