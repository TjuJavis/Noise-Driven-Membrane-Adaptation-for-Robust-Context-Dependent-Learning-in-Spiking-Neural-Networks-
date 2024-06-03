function [PerCorrect, FiringRate, FIndex, W12perTrial, W23perTrial, RasterPlot] = ...
    spikingNetworkContextLearning(std,simd)
% spikingNetworkContextLearning
% 尖峰网络上下文学习
%   nTrial  - Number of trials. Numerous other parameters are specified in 
%             the function itself.
%   nTrial - 试验的数量。函数本身还指定了许多其他参数
%
% RETURN
% 返回
%   PerCorrect  - Percent correct with dimensions: nTrial x 1.
%                 尺寸正确百分比: nTrial x 1.
%
%   FiringRate  - Firing rate with dimensions: nTrial x nStim x nHippo.
%               - 与尺寸相关的激发速率： nTrial x nStim x nHippo
%
%   FIndex      - Functional index as binary matrix. A strong weight 
%                 connection from the 1st to 2nd layer indicates this 
%                 connection being funcational. This index has the 
%                 dimensions: 1 x nHippo.
%               - 函数索引为二进制矩阵。从第1层到第2层的强权重连接表明该连接是功能连接。
%                 这个索引的尺寸是:1 x nHippo。
%
%   W12PerTrial - Weight matrix from 1st to 2nd layer for all trials. This 
%                 matrix has the dimensions: nTrial x nInput x nHippo.
%               - 所有试验从第1层到第2层的权重矩阵。
%
%   W23PerTrial - Weight matrix from 2nd to 3rd layer for all trials. This
%                 matrix has the dimensions: nTrial x nHippo x nOutput.
%               - 所有试验从第2层到第3层的权重矩阵。
%
% DESCRIPTION
%   This is the main network simulation. It inlcude the
%   这是主要的网络模拟，它包括：
%   - initialization of the network
%      网络的初始化。
%   - the spiking simulation for each trial with its phase of the trial and 
%     phase of reply.
%     对每个试验的尖峰模拟及其阶段的试验和阶段的答复。
%   - during replay the synaptic weights between 1st/2nd and 2nd/3rd layer
%     are adapted.
%     在重放的过程中，1/2层和2/3层的突触权重在适应学习。
%

nTrial = 130;
IntvlTrial  = [0 4000]; % ms   每一次实验的时长
IntvlReplay = [0 400];  % ms   每一次重放的时长
dt          = 0.5;      % time step  时间步长
dtWindow    = 10;       % ms  窗的步长
TimeTrial   = ( IntvlTrial(1)  : dt : IntvlTrial(2)  )';
TimeReplay  = ( IntvlReplay(1) : dt : IntvlReplay(2) )';
nTimeTrial  = length(TimeTrial);
nTimeReplay = length(TimeReplay);
nWindow     = dtWindow/dt;
V_PEAK      = 0;            % in Volts, these are 0 mV. 膜电位峰值
V_TH        = -50*10^-3;    % in Volts, these are -50 mV.  膜电位阈值
V_RESET     = -70*10^-3;    % in Volts, these are -70 mV.  静息电位
ETA         = 10^-6;        % Threshold for equal  相等的阈值？？为什么这么小？？误差？误差小于ETA则认为相等？？

%            Context and Place   Odor（气味）    
% Input for: A1 | B1 | A2 | B2 | X | Y   输入向量-A1X
InVec       = [1 0 0 0 1 0];

% Per definition the rewarded stimuli are: A1X  A2X  B1Y  B2Y.
% 定义可以获得奖励的刺激：A1X  A2X  B1Y  B2Y.
reward      = @(X) (X(1) && X(5)) || (X(3) && X(5)) ...
                || (X(2) && X(6)) || (X(4) && X(6));
stimulusIndex = @(X) 1*X(1)+2*X(2)+3*X(3)+4*X(4)+4*X(6); % 刺激指数

% Output action vector: Dig | Move  输出动作向量
OutVec  = [0 0];

% Number of neurons to simulate the hippocampus. 海马层模拟的神经元数目
nHippo  = 8; %一共8个海马细胞
nIn     = length(InVec); % 输入的向量长度
nOut    = length(OutVec); % 输出的向量长度
nStim   = 8; % 刺激数

% Randomly initialize the synaptic coupling strengths (weights). 随机初始化突触权重
% Per random some of these have place cell selectivity.  一些随机表现了细胞选择性？？
W12 = rand(nIn,nHippo);
W23 = rand(nHippo,nOut);
W22 = ones(nHippo,nHippo)   -eye(nHippo); % Inhibition weights 抑制权重（横向）
W33 = ones(nOut,nOut)       -eye(nOut);

% Number of steps in the history. 一个记录历史走过步数的计数器
nHist       = 2;
InVecHst    = zeros(nHist,nIn);
HippoVecHst = zeros(nHist,nHippo);
OutVecHst   = zeros(nHist,nOut);

% Buffer for spikes within the STDP window.  STDP窗的标记尖峰
nMaxSpike   = 10; % 最大尖峰数
T1          = TimeBuffer(nMaxSpike,nIn,dtWindow);
T2          = TimeBuffer(nMaxSpike,nHippo,dtWindow);
T3          = TimeBuffer(nMaxSpike,nOut,dtWindow); % 构造了一个类

% For performance reasons randomize all indices. 出于性能原因，随机化所有索引
Index       = rand(nTrial,2);

% Percent correct detected. 正确的检测出百分比
PerCorrect  = zeros(nTrial,1);
nMaxTime    = 1200; % 最大时间数目
nMaxSample  = 100; % 样本的最大数目
RasterPlot  = ManySlotBuffer(nStim*nHippo,nMaxSample,nMaxTime); % 构造了一个类？？

% Set the options for the LIF neuron and STDP rule. 做出LIF神经元和STDP规则的选择
opt.V_PEAK  = V_PEAK;
opt.V_TH    = V_TH;
opt.V_RESET = V_RESET;
opt.dt      = dt;

% Define matrices for weights per trial. 定义每次实验的权重
W12perTrial = zeros(nTrial,nIn,nHippo);
W23perTrial = zeros(nTrial,nHippo,nOut);

% *************************************************************************
% Loop over all trials.  对所有实验（130次实验）进行loop循环
% *************************************************************************
j=1;
k=1;
for iTrial = 1:nTrial
    % Start trial in a random state. 以一种随机的模式开始实验-->通过使用随机权重选择输入triplet
    InVec = zeros(1,nIn);
    InVec(1+round(Index(iTrial,1)*3))   = 1; % round()四舍五入函数
    InVec(1+4+(Index(iTrial,2)>0.5))    = 1;
    % Reset counter for buffers. 为了标记重置计数器
    nHistCount  = 0;
    InVecHst(1+nHistCount,:) = InVec;
    TraceV1     = nan(nTimeTrial,nIn);
    TraceV2     = nan(nTimeTrial,nHippo);
    TraceV3     = nan(nTimeTrial,nOut);
    rewarded    = 0;
    nMoveSpike  = 0;
    nDigSpike   = 0;
    % Initialize membrane potentials. 初始化膜电位
    V1      = repmat(V_RESET,[1 nIn]);
    V2      = repmat(V_RESET,[1 nHippo]);
    V3      = repmat(V_RESET,[1 nOut]);
    NoiseV1 = simd*10^-6*randn(nTimeTrial,1); % 初始化噪声
    NoiseV2 = simd*10^-6*randn(nTimeTrial,1);
    NoiseV3 = simd*10^-6*randn(nTimeTrial,1);
    nThDigSpike     = 5; % dig尖峰的阈值
    nThMoveSpike    = 5; % move尖峰的阈值
    iLastTime       = 1; % 结束标志
    for iTime = 1 : nTimeTrial
        t           = TimeTrial(iTime);
        opt.I       = InVec+randn * std;
        % opt.I       = InVec;

        opt.G       = repmat(.1,[1 nIn]);        
        V1          = lifModel(t, V1,opt) + NoiseV1(iTime); % LIF模型电压方程
        [~,mi]      = max((V1-V_RESET)*W12 - (V2-V_RESET)*W22); % Ij*
        opt.I       = zeros(1,nHippo);
        opt.I(mi)   = randn * std+ .98; % 从均值为0.98，标准差为0.1的正态分布中随机抽取 % nA % Ihippo的电流脉冲
        % opt.I(mi)   = .98;

        V2          = lifModel(t, V2,opt) + NoiseV2(iTime);
        [~,mi]      = max((V2-V_RESET)*W23 - (V3-V_RESET)*W33);
        opt.I       = zeros(1,nOut);
        opt.I(mi)   = randn * std+ .96; % 从均值为0.96，标准差为0.1的正态分布中随机抽取 % nA % Imotor的电流脉冲
        % opt.I(mi)   = .96;

        V3          = lifModel(t, V3,opt) + NoiseV3(iTime);
        TraceV1(iTime,:) = V1;
        TraceV2(iTime,:) = V2;
        TraceV3(iTime,:) = V3;
        % Register any spikes at the output in the output vector. 在输出向量中注册输出处的任何峰值。
        OutVec = zeros(1,nOut);
        OutVec(abs(V3-V_PEAK)<=ETA) = 1; % abs()绝对值函数
        % Keep the history of the states/firings. 保持历史的状态/激发
        if any(abs(V2-V_PEAK)<=ETA) % any():检查矩阵中是否有非零元素
            HippoVecHst(1+nHistCount,:) = double(abs(V2-V_PEAK)<=ETA);
        end
        if any(abs(V3-V_PEAK)<=ETA)
            OutVecHst(1+nHistCount,:) = double(abs(V3-V_PEAK)<=ETA);
        end
        nMoveSpike  = nMoveSpike    + OutVec(2);
        nDigSpike   = nDigSpike     + OutVec(1);
        % Dig ? 挖掘？？
        if nDigSpike>=nThDigSpike
            OutVec(1)       = 1;
            OutVecHst(1+nHistCount,:) = OutVec;
            rewarded = reward(InVec);
            for iHippo = 1:nHippo
                iSlot   = sub2ind([nStim nHippo],stimulusIndex(InVec),iHippo);
                DataRow = [iTrial; iTime-iLastTime+1; ...
                    abs(TraceV2(iLastTime:iTime,iHippo)-V_PEAK)<=ETA];
                RasterPlot.addEntryToSlot(iSlot,DataRow);
            end
            break;
        end
        % Move?  移动？？
        if nMoveSpike>=nThMoveSpike
            nThMoveSpike    = 5;
            nThDigSpike     = max(nThDigSpike - 1,  0);
            nMoveSpike      = 0;
            OutVec(2)       = 1;
            OutVecHst(1+nHistCount,:) = OutVec;
            for iHippo = 1:nHippo
                iSlot   = sub2ind([nStim nHippo],stimulusIndex(InVec),iHippo);
                DataRow = [iTrial; iTime-iLastTime+1; ...
                    abs(TraceV2(iLastTime:iTime,iHippo)-V_PEAK)<=ETA];
                RasterPlot.addEntryToSlot(iSlot,DataRow);
            end
            iLastTime = iTime+1;
            % Move to the other place.  移动到其他位置
            Tmp = InVec(3:4);
            InVec(3:4) = InVec(1:2);
            InVec(1:2) = Tmp;
            % Then percept changes too. 对象也改变了
            InVec(5) = InVec(6);
            InVec(6) = ~InVec(5);
            % Increment the counter for the buffer. 增加缓冲区的计数器
            nHistCount = mod(nHistCount + 1,nHist);
            InVecHst(1+nHistCount,:) = InVec;
            % Assume there is a break and all the membrane potential return
            % to their resting state. 
            % 假设有一个break，所有的膜电位恢复到它们的静止状态。
            V1 = repmat(V_RESET,[1 nIn]);
            V2 = repmat(V_RESET,[1 nHippo]);
            V3 = repmat(V_RESET,[1 nOut]);            
        end
    end
    PerCorrect(iTrial) = rewarded;
    
    % Replay the sequence with the last 1+nHistCount steps. 
    % 用最后1+nHistCount步骤播放序列。
     i=1;
     h=1;
     
    for iHist = 1 : (1+nHistCount)
        InVec       = InVecHst(iHist,:);
        HippoVec    = HippoVecHst(iHist,:);
        OutVec      = OutVecHst(iHist,:);
        % Assume there was a break and all membrane potentials return
        % to their resting state value.
        % 假设有一个break，所有的膜电位恢复到它们的静息状态值。
        V1          = repmat(V_RESET,[1 nIn]);
        V2          = repmat(V_RESET,[1 nHippo]);
        V3          = repmat(V_RESET,[1 nOut]);
        TraceV1     = nan(nTimeReplay,nIn);
        TraceV2     = nan(nTimeReplay,nHippo);
        TraceV3     = nan(nTimeReplay,nOut);
        TraceW12    = nan(nTimeReplay,nIn,nHippo);
        TraceW23    = nan(nTimeReplay,nHippo,nOut);
        % Clear out any remaining spike times.
        % 清除所有剩余的尖峰时间。
        T1.clear();
        T2.clear();
        T3.clear();
        % Start the replay sequence.
        % 启动重播序列。
        for iTime = 1 : nTimeReplay
            t       = TimeReplay(iTime);
            % Replay in forward direction --- per STDP strenghening
            % 前向重复-每次STDP都会加强
            if rewarded
                opt.I   = InVec;
                V1      = lifModel(t, V1, opt);
                opt.I   = .98*HippoVec;
                V2      = lifModel(t, V2, opt);
                opt.I   = .96*OutVec;
                V3      = lifModel(t, V3, opt);
            % Replay in inverse direction --- per STDP weakening
            % 反向重复-每次STDP减弱
            else
                opt.I   = .96*InVec;
                V1      = lifModel(t, V1, opt);
                opt.I   = .98*HippoVec;
                V2      = lifModel(t, V2, opt);
                opt.I   = OutVec;
                V3      = lifModel(t, V3, opt);
            end                    
            % Retire spike times which are too old.
            % 退休高峰时间太长。？？
            T1.retire(t);
            T2.retire(t);
            T3.retire(t);
            % Register new spike times.
            % 注册新的尖峰时间
            T1.addTime(t,abs(V1-V_PEAK)<=ETA);
            T2.addTime(t,abs(V2-V_PEAK)<=ETA);
            T3.addTime(t,abs(V3-V_PEAK)<=ETA);
            % Update the synaptic weights.
            % 更新突触权重
               
            if iTime >= nWindow
                for iIn = 1:nIn
                    TimePre     = T1.time(iIn);
                    nPre        = length(TimePre);
                    if nPre==0, continue; end
                    % n_timepre = 1;
                    for iHippo = 1:nHippo
                        TimePost    = T2.time(iHippo);
                        nPost       = length(TimePost);
                        % Are there any spikes for the pre- and the 
                        % post-synaptic neuron in the time window?
                        % 时间窗内是否有突触前/后的神经元有尖峰？？
                        if nPre>0 && nPost>0
                            opt.TimePre    = TimePre;
                            opt.TimePost   = TimePost;
                            try_TimePre_In(i,j)=TimePre;
                            try_TimePost_In(i,j)=TimePost;
                            if i==1
                                opt.TimePre_tryn    = 0;
                                opt.TimePost_tryn   = 0;
                            else
                                opt.TimePre_tryn    =  try_TimePre_In(i-1,j);
                                opt.TimePost_tryn   = try_TimePost_In(i-1,j);
                            end
                            i=i+1;
                            W12(iIn,iHippo) = stdpModel(...
                                                t,W12(iIn,iHippo),opt);
                        end
                    end
                end
                
               
                for iHippo = 1:nHippo
                    TimePre     = T2.time(iHippo);
                    nPre        = length(TimePre);
                    if nPre==0, continue; end
                    for iOut = 1:nOut
                        TimePost    = T3.time(iOut);
                        nPost       = length(TimePost);
                        % Are there any spikes for the pre- and the 
                        % post-synaptic neuron in the time window?
                        if nPre>0 && nPost>0
                            opt.TimePre     = TimePre;
                            opt.TimePost    = TimePost;
                            try_TimePre_Hippo(h,k)=TimePre;
                            try_TimePost_Hippo(h,k)=TimePost;
                            if h==1
                                opt.TimePre_tryn    = 0;
                                opt.TimePost_tryn   = 0;
                            else
                                opt.TimePre_tryn    = try_TimePre_Hippo(h-1,k);
                                opt.TimePost_tryn   = try_TimePost_Hippo(h-1,k);
                            end
                            h=h+1;
                            W23(iHippo,iOut) = stdpModel(...
                                                t,W23(iHippo,iOut),opt);
                        end
                    end
                end
            end
            TraceV1(iTime,:)    = V1;
            TraceV2(iTime,:)    = V2;
            TraceV3(iTime,:)    = V3;
            TraceW12(iTime,:,:) = W12;
            TraceW23(iTime,:,:) = W23;
        end
    end
    W12perTrial(iTrial,:,:) = W12;
    W23perTrial(iTrial,:,:) = W23; 
    j=j+1;
    k=k+1;
end

opt.nTrial      = nTrial; 
opt.nStim       = nStim;
opt.nCell       = nHippo;
opt.nMaxSample  = nMaxSample;

% Calculate the firing rate for each hippocampal cell, trial, and stimulus. 
% 计算每一层细胞的激发率
FiringRate = rasterPlotToFiringRate(RasterPlot, opt);
% Calculate a binary vector indicating whether a hippocampal cell is part
% of the functional network or not.
% 计算二进制向量判断海马细胞是否是功能网络中的一部分
FIndex = max(W12,[],1)>(1-ETA);

