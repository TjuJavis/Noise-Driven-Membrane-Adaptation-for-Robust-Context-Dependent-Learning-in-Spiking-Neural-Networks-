function D = meanWoutNaN(D, dim)
% meanWoutNaN
%   D   - N维数据矩阵。
%   dim - 用于计算均值的维度。
%
% RETURN
%   D   - (N-1)维数据矩阵。在Matlab中，维度dim被保留并设置为1。
%
% DESCRIPTION
%   计算沿维度dim的D的均值，不包括NaN条目。

%   Florian Raudies, 09/07/2014, Boston University.

Index   = isnan(D);  % 找到NaN的索引。
D(Index)= 0;         % 将NaN替换为零。
D       = sum(D, dim)./(eps + size(D, dim) - sum(Index, dim));
