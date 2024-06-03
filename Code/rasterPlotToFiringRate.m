function FiringRate = rasterPlotToFiringRate(RasterPlot, opt)
% rasterPlotToFiringRate
%   RasterPlot  - ManySlotBuffer的对象实例，假设其维度为：nSlots x nEntry x nData。
%   opt         - 包含字段的结构体：
%                 * nTrial      - 试次数。
%                 * nStim       - 刺激数量。
%                 * nCell       - 神经元数量。
%                 * nMaxSample  - 每个神经元的最大样本数。
%                 * dt          - 毫秒单位的时间步长。
%
% RETURN
%   FiringRate - 每个试次、刺激和神经元的激发率矩阵。
%                矩阵的维度为：nTrial x nStim x nCell。
%
% DESCRIPTION
%   该函数将RasterPlot对象（包含神经元的脉冲计数数据）转换为激发率矩阵。激发率矩阵包含每个试次、刺激和神经元的平均脉冲率。

%   Florian Raudies, 09/07/2014, 波士顿大学.

nTrial      = opt.nTrial;
nStim       = opt.nStim;
nCell       = opt.nCell;
nMaxSample  = opt.nMaxSample;
dt          = opt.dt;

% 使用堆栈容器来收集所有样本。
FiringRate          = zeros(nTrial, nStim, nCell);
FiringRateSamples   = StackContainer(nTrial * nStim * nCell, nMaxSample);

% 对于所有槽位（它们都是组合的刺激和海马神经元）。
for iSlot = 1:nStim * nCell
    % 将索引拆分为刺激和海马神经元的索引。
    [iStim, iHippo]  = ind2sub([nStim, nCell], iSlot);
    DataTrialSpike  = RasterPlot.getAllEntryForSlot(iSlot);
    
    % 从索引3到末尾获取脉冲计数。
    SpikeCount      = sum(DataTrialSpike(:, 3:end), 2);
    % 从索引2获取步数。
    Steps           = DataTrialSpike(:, 2);
    % 从索引1获取试次数。
    DataTrial       = DataTrialSpike(:, 1);
    % 计算脉冲速率。
    nSample         = size(DataTrialSpike, 1);
    SpikeRate       = SpikeCount ./ (Steps * dt);
    
    % 对于每个样本，将该数据点的脉冲率添加到由试次、刺激和神经元索引组成的矩阵中。
    for iSample = 1:nSample
        iTrial = DataTrial(iSample);
        iData = sub2ind([nTrial, nStim, nCell], iTrial, iStim, iHippo);
        FiringRateSamples.push(iData, SpikeRate(iSample)); 
    end
end

% 将所有计算的脉冲率从一个试次转换为均值脉冲率。如果在试次中多次出现相同的刺激，则会发生这种情况。
for iData = 1:nTrial * nStim * nCell
    sumFiringRate = 0;
    nEntry = FiringRateSamples.numel(iData);
    
    if nEntry
        while ~FiringRateSamples.empty(iData)
            sumFiringRate = sumFiringRate + FiringRateSamples.pop(iData);   
        end
        
        [iTrial, iStim, iHippo] = ind2sub([nTrial, nStim, nCell], iData);
        FiringRate(iTrial, iStim, iHippo) = sumFiringRate / nEntry;
    end
end
