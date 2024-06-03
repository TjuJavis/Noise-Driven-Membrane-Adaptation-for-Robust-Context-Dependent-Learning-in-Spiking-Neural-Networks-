function w = stdpModel(~, w, opt)
% stdpModel
%   t       - 时间，以毫秒为单位。
%   w       - 此权重模拟突触强度。
%   opt     - 包含字段的结构体：
%             * TimePre  - 来自前突触神经元的射击时刻。
%             * TimePost - 来自后突触神经元的射击时刻。
%
% RETURNS
%   w       - 调整后的权重。
%
% DESCRIPTION
%   带有突触增强和突触抑制的时序相关塑性（STDP）模型。

%   Florian Raudies, 09/07/2014, 波士顿大学.

TAU_PLUS    = 10;   % 长时程增强（LTP）时间常数，毫秒
TAU_MINUS   = 10;   % 长时程抑制（LTD）时间常数，毫秒
TAU_W       = 10;   % 权重更新的时间常数，毫秒
A_PLUS      = 1.2;  % 长时程增强（LTP）的振幅。
A_MINUS     = -.4;  % 长时程抑制（LTD）的振幅。
W_MIN       = 0;    % 权重的最小值。
W_MAX       = 1;    % 权重的最大值。
eta         = 1 / (TAU_W / opt.dt); % 学习速率，其中opt.dt是时间步长。

% 获取前突触和后突触神经元的射击时刻。
TimePre     = opt.TimePre;
TimePost    = opt.TimePost;
nPre        = length(TimePre);
nPost       = length(TimePost);

% 计算时间差。
% 将后突触神经元的射击时刻复制为矩阵，每一列都是相同的时刻。
% 将前突触神经元的射击时刻复制为矩阵的转置，每一行都是相同的时刻。
% 然后，通过矩阵相减，得到一个矩阵 Delta，表示每对前后突触神经元的时间差。
Delta = repmat(TimePost(:), [1, nPre]) - repmat(TimePre(:)', [nPost, 1]);
Pos         = Delta > 0; % 前突触在后突触之前。
Neg         = Delta < 0; % 后突触在前突触之前。

% 请注意，当具有大输入信号时，可能会超过W_MAX！
% 根据时序相关塑性（STDP）模型的规则，根据前后突触神经元的射击时刻差异，更新权重。

% 计算正时间差（前突触在后突触之前）对应的影响。
positiveInfluence = (W_MAX - w) * A_PLUS * sum(exp(-Delta(Pos) / TAU_PLUS));

% 计算负时间差（后突触在前突触之前）对应的影响。
negativeInfluence = (W_MIN - w) * A_MINUS * sum(exp(+Delta(Neg) / TAU_MINUS));

% 根据STDP规则，计算新的权重。
w = w + eta * (positiveInfluence - negativeInfluence);

