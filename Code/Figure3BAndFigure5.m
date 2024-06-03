clc
clear
close all

% *************************************************************************
% 用于重现图3B和图5的MATLAB代码。
%
% 通过多次运行具有不同随机数生成器初始化的所有试次，
% 收集关于选择性指数的统计数据。在每次运行中，权重初始化和膜电位的噪声波动也是不同的。
%
% 设置变量'SIMULATE'来重新运行模拟，这大约需要6-7小时。
% 为了方便起见，也提供了模拟数据。
%
%   Florian Raudies, 09/07/2014, 波士顿大学。
% *************************************************************************

% 定义图表文字大小。
LABEL_SIZE  = 22; % 标签字体大小
TITLE_SIZE  = 22; % 标题字体大小

% 定义保存图表的路径。
figurePath  = './'; % 当前目录作为保存路径

% 控制是否进行模拟的开关变量。
SIMULATE    = 1; % 设置为1时进行模拟，设置为0时直接加载结果数据

% 定义试验和运行的参数。
nTrial              = 130; % 每轮运行的试验数量
nRun                = 2; % 总共运行的次数
nBlock              = 30;  % 块的数量（未在此代码段使用）
simd                = 1;
tau                 = 2;
Am                  = 1;
% 初始化存储每次运行每次试验后的正确率。
PerCorrectPerTrial  = zeros(nRun,nTrial);

% 初始化存储发射率和选择性指数的单元格数组。
FiringRatePerTrial  = cell(nRun,1);
FIndexPerTrial      = cell(nRun,1);

% 定义每层的神经元数量。
nIn                 = 6;  % 输入神经元的数量
nHippo              = 8;  % 海马神经元的数量
nOut                = 2;  % 输出神经元的数量

% 定义每个试验的时间长度。
nTimeTrial          = 801;

% 初始化存储每次运行每次试验结束后第一层到第二层、第二层到第三层的权重。
WeightLayer1To2     = zeros(nRun,nTrial,nIn,nHippo);
WeightLayer2To3     = zeros(nRun,nTrial,nHippo,nOut);

% 生成存储网络模拟数据的文件名。
fileName            = sprintf('NetworkSimulation%dRuns',nRun);


if SIMULATE
    % 如果SIMULATE为1，则运行模拟。
    for iRun = 1:nRun
        fprintf('Run %d.\n',iRun); % 在命令窗口输出当前运行次数
        rng(1+iRun); % 为随机数生成器设置种子，保证每次运行的随机性
        
        % 调用spikingNetworkContextLearning函数运行神经网络模拟，并返回各种结果。
        [PerCorrect, FiringRate, FIndex, W12perTrial, W23perTrial] ...
            = spikingNetworkContextLearning(nTrial, simd, tau, Am, 2);
        
        % 存储当前运行的各种数据。
        PerCorrectPerTrial(iRun,:)  = PerCorrect;       % 正确率数据
        FiringRatePerTrial{iRun}    = FiringRate;       % 发射率数据
        FIndexPerTrial{iRun}        = FIndex;           % 选择性指数数据
        WeightLayer1To2(iRun,:,:,:) = W12perTrial;      % 第一层到第二层权重数据
        WeightLayer2To3(iRun,:,:,:) = W23perTrial;      % 第二层到第三层权重数据
        fprintf('Overall percent correct trials: %2.2f.\n',...
            sum(PerCorrect)/nTrial*100); % 输出当前运行的总正确率百分比
    end

    % 保存所有收集到的数据到指定的文件中。
    save(fileName, 'PerCorrectPerTrial', 'FiringRatePerTrial', ...
        'FIndexPerTrial', 'WeightLayer1To2', 'WeightLayer2To3');

    for iRun = 1:nRun
        fprintf('Run %d.\n',iRun); % 在命令窗口输出当前运行次数
        rng(3+iRun); % 为随机数生成器设置种子，保证每次运行的随机性
        
        % 调用spikingNetworkContextLearning函数运行神经网络模拟，并返回各种结果。
        [PerCorrect, FiringRate, FIndex, W12perTrial, W23perTrial] ...
            = spikingNetworkContextLearning(nTrial, simd, tau, Am, 1);
        
        % 存储当前运行的各种数据。
        PerCorrectPerTrial2(iRun,:)  = PerCorrect;       % 正确率数据
        FiringRatePerTrial2{iRun}    = FiringRate;       % 发射率数据
        FIndexPerTrial2{iRun}        = FIndex;           % 选择性指数数据
        WeightLayer1To22(iRun,:,:,:) = W12perTrial;      % 第一层到第二层权重数据
        WeightLayer2To32(iRun,:,:,:) = W23perTrial;      % 第二层到第三层权重数据
        fprintf('Overall percent correct trials: %2.2f.\n',...
            sum(PerCorrect)/nTrial*100); % 输出当前运行的总正确率百分比
    end
    save(fileName, 'PerCorrectPerTrial2', 'FiringRatePerTrial2', ...
        'FIndexPerTrial2', 'WeightLayer1To22', 'WeightLayer2To32');
    
else
    % 如果SIMULATE为0，则从之前保存的数据文件中加载结果。
    load(fileName); 
end

% *************************************************************************
% 正确检测图的图形。
% *************************************************************************
TrialWindow         = repmat(1/30, [1 30]);
PerCorrectPerTrial  = imfilter(double(PerCorrectPerTrial),...
                               TrialWindow,'same',0)*100;
PerCorrectPerTrial2  = imfilter(double(PerCorrectPerTrial2),...
                               TrialWindow,'same',0)*100;
TrialIndex          = 30:100;
PerCorrectPerTrial  = PerCorrectPerTrial(:,TrialIndex);
PerCorrectPerTrial2  = PerCorrectPerTrial2(:,TrialIndex);


figure('Name','Figure 9', 'NumberTitle','off', 'Position',[50 50 800 500]);

errorarea(TrialIndex,mean(PerCorrectPerTrial),...
                     std(PerCorrectPerTrial),[.0 .0 .0],'r');
hold on
plot([30 100],[100 100],'--k');
hold on
errorarea(TrialIndex,mean(PerCorrectPerTrial2),...
                     std(PerCorrectPerTrial2),[.0 .0 .0],'k');
hold off
axis([30 100 0 110]);
xlabel('Sliding 30 Trial Window','FontSize',LABEL_SIZE);
ylabel('Performance (Percent Correct)','FontSize',LABEL_SIZE);
set(gca,'FontSize',LABEL_SIZE);
title(sprintf('N=%d',nRun),'FontSize',TITLE_SIZE);
print('-deps',sprintf('%sFigurePercentCorrect%dRuns.eps',figurePath,nRun));

% % *************************************************************************
% % 选择性指数的图形。
% % *************************************************************************
% nBin = 4;
% [nTrial, nStim, nHippo]   = size(FiringRatePerTrial{1});
% SIPosPerTrial           = zeros(nRun,nBin,nHippo);
% SIItemPerTrial          = zeros(nRun,nBin,nHippo);
% SIContextPerTrial       = zeros(nRun,nBin,nHippo);
% opt.nBin                = nBin;
% opt.nTrial              = nTrial;
% opt.nCell               = nHippo;
% opt.nStim               = nStim;
% for iRun = 1:nRun
%     FiringRate                          = FiringRatePerTrial{iRun};
%     [SIPos, SIItem, SIContext]            = firingRateToSI(FiringRate,opt);
%     FIndex                              = FIndexPerTrial{iRun};
%     SIPosPerTrial(iRun,:,:)             = SIPos;
%     SIItemPerTrial(iRun,:,:)            = SIItem;
%     SIContextPerTrial(iRun,:,:)         = SIContext;
%     SIPosPerTrial(iRun,:,~FIndex)       = NaN;
%     SIItemPerTrial(iRun,:,~FIndex)      = NaN;
%     SIContextPerTrial(iRun,:,~FIndex)   = NaN;
% end
% SIPosPerTrial(SIPosPerTrial==0)         = NaN;
% SIItemPerTrial(SIItemPerTrial==0)       = NaN;
% SIContextPerTrial(SIContextPerTrial==0) = NaN;
% MeanSIPos       = squeeze(meanWoutNaN(SIPosPerTrial,1));
% SemSIPos        = squeeze(semWoutNaN(SIPosPerTrial,1));
% MeanSIItem      = squeeze(meanWoutNaN(SIItemPerTrial,1));
% SemSIItem       = squeeze(semWoutNaN(SIItemPerTrial,1));
% MeanSIContext   = squeeze(meanWoutNaN(SIContextPerTrial,1));
% SemSIContext    = squeeze(semWoutNaN(SIContextPerTrial,1));
% XNAME = {'1st','2nd','3rd','4th'};
% 
% % *************************************************************************
% % 地点的选择性指数。
% % *************************************************************************
% figure('Name','Figur 5A', 'NumberTitle','off', ...
%        'Position',[50 50 1200 600],'PaperPosition',[1 1 14 8]);
% for iHippo = 1:nHippo
%     subplot(2,nHippo/2,iHippo);
%         bar(MeanSIPos(:,iHippo),'EdgeColor',[0 0 0],'FaceColor',[0.7 0.7 0.7]);
%         hold on;
%         errorbar(1:4,MeanSIPos(:,iHippo),SemSIPos(:,iHippo),'k.','LineWidth',1.5);
%         plot([1 4],[1 1],'--k','LineWidth',1.5);
%         hold off;
%         ylim([0 1.1]);
%         set(gca,'XTick',[1 2 3 4],'XTickLabel',XNAME);
%         ylabel('SI place','FontSize',LABEL_SIZE);
%         set(gca,'FontSize',LABEL_SIZE);
%         title(sprintf('Cell %d',iHippo),'FontSize',TITLE_SIZE);
% end
% print('-depsc',sprintf('%sFigureSIPlace.eps',figurePath));
% 
% 
% % *************************************************************************
% % 配对t检验。显著性区间为0.05或5%。
% % *************************************************************************
% fprintf('ttest2 for first and last 30 trials based on SI for place.\n');
% for iHippo = 1:nHippo
%     hypo = ttest2(SIPosPerTrial(:,1,iHippo),SIPosPerTrial(:,4,iHippo),.05);
%     fprintf('Hippocampal cell %d is significantly different %d.\n',iHippo,hypo);
% end
% 
% 
% % *************************************************************************
% % 物品/地点的选择性指数。
% % *************************************************************************
% figure('Name','Figure 5B', 'NumberTitle','off', ...
%        'Position',[50 50 1200 600],'PaperPosition',[1 1 14 8]); 
% for iHippo = 1:nHippo
%     subplot(2,nHippo/2,iHippo);
%         bar(MeanSIItem(:,iHippo),'EdgeColor',[0 0 0],'FaceColor',[0.7 0.7 0.7]);
%         hold on;
%         errorbar(1:4,MeanSIItem(:,iHippo),SemSIItem(:,iHippo),'k.','LineWidth',1.5);
%         plot([1 4],[1 1],'--k','LineWidth',1.5);
%         hold off;
%         ylim([0 1.1]);
%         set(gca,'XTick',[1 2 3 4],'XTickLabel',XNAME);
%         ylabel('SI item','FontSize',LABEL_SIZE);
%         set(gca,'FontSize',LABEL_SIZE);
%         title(sprintf('Cell %d',iHippo),'FontSize',TITLE_SIZE);
% end
% print('-depsc',sprintf('%sFigureSIItem.eps',figurePath));
% 
% 
% % *************************************************************************
% % 配对t检验。显著性区间为0.01或1%。
% % *************************************************************************
% fprintf('ttest2 for first and last 30 trials based on SI for item.\n');
% for iHippo = 1:nHippo
%     hypo = ttest2(SIItemPerTrial(:,1,iHippo),SIItemPerTrial(:,4,iHippo),.01);
%     fprintf('Hippocampal cell %d is significantly different %d.\n',iHippo,hypo);
% end
% 
% 
% % *************************************************************************
% % 上下文的选择性指数。
% % *************************************************************************
% figure('Name','Figure 5C','NumberTitle','off', ...
%        'Position',[50 50 1200 600],'PaperPosition',[1 1 14 8]);
% for iHippo = 1:nHippo
%     subplot(2,nHippo/2,iHippo);
%         bar(MeanSIContext(:,iHippo),'EdgeColor',[0 0 0],'FaceColor',[0.7 0.7 0.7]);
%         hold on;
%         errorbar(1:4,MeanSIContext(:,iHippo),SemSIContext(:,iHippo),'k.','LineWidth',1.5);
%         plot([1 4],[1 1],'--k','LineWidth',1.5);
%         hold off;
%         ylim([0 1.1]);
%         set(gca,'XTick',[1 2 3 4],'XTickLabel',XNAME);
%         ylabel('SI context','FontSize',LABEL_SIZE);
%         set(gca,'FontSize',LABEL_SIZE);
%         title(sprintf('Cell %d',iHippo),'FontSize',TITLE_SIZE);
% end
% print('-depsc',sprintf('%sFigureSIContext.eps',figurePath));
% 
% % *************************************************************************
% % 配对t检验。显著性区间为0.01或1%。
% % *************************************************************************
% fprintf('ttest2 for first and last 30 trials based on SI for context.\n');
% for iHippo = 1:nHippo
%     hypo = ttest2(SIContextPerTrial(:,1,iHippo),SIContextPerTrial(:,4,iHippo),.01);
%     fprintf('Hippocampal cell %d is significantly different %d.\n',iHippo,hypo);
% end
% 
% 
% % *************************************************************************
% % 使用将层1连接到层2的权重计算每个块的二元性。
% % *************************************************************************
% Binariness12    = binariness(WeightLayer1To2);
% Binariness23    = binariness(WeightLayer2To3);
% FIndexPerTrial  = cell2mat(FIndexPerTrial);
% FIndexPerTrial  = permute(repmat(FIndexPerTrial,[1 1 nTrial nIn]),[1 3 4 2]);
% Binariness12(~FIndexPerTrial) = NaN;
% Binariness12 = squeeze(meanWoutNaN(Binariness12,3));
% Binariness12PerBin = zeros(nRun,nBin,nHippo);
% for iBin = 1:nBin
%     Binariness12PerBin(:,iBin,:) = meanWoutNaN(...
%         Binariness12(:,(iBin-1)*nBlock+(1:nBlock),:),2);
% end
% MeanBinariness = squeeze(meanWoutNaN(Binariness12PerBin,1));
% SemBinariness = squeeze(semWoutNaN(Binariness12PerBin,1));
% 
% 
% figure('Name','Figure 5D','NumberTitle','off',...
%        'Position',[50 50 1200 600],'PaperPosition',[1 1 14 8]);
% for iHippo = 1:nHippo
%     subplot(2,nHippo/2,iHippo);
%         bar(MeanBinariness(:,iHippo),'EdgeColor',[0 0 0],'FaceColor',[0.7 0.7 0.7]);
%         hold on;
%         errorbar(1:4,MeanBinariness(:,iHippo),SemBinariness(:,iHippo),'k.','LineWidth',1.5);
%         plot([1 4],[1 1],'--k','LineWidth',1.5);
%         hold off;
%         ylim([0 1.1]);
%         set(gca,'XTick',[1 2 3 4],'XTickLabel',XNAME);
%         ylabel('Binariness','FontSize',LABEL_SIZE);
%         set(gca,'FontSize',LABEL_SIZE);
%         title(sprintf('Cell %d',iHippo),'FontSize',TITLE_SIZE);
% end
% print('-depsc',sprintf('%sFigureSIBinariness.eps',figurePath));
% 
% 
% % *************************************************************************
% % 二值性的配对t检验。显著性区间为0.01或1%。
% % *************************************************************************
% fprintf('ttest2 for first and last 30 trials based on binariness.\n');
% for iHippo = 1:nHippo
%     hypo = ttest2(Binariness12PerBin(:,1,iHippo),Binariness12PerBin(:,4,iHippo),.01);
%     fprintf('Hippocampal cell %d is significantly different %d.\n',iHippo,hypo);
% end
