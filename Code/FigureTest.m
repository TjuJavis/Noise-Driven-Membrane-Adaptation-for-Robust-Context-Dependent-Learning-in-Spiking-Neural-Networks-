clc % 清除命令窗口
clear % 清除所有变量
close all % 关闭所有图窗

% *************************************************************************
% 复现图n。
% nTrial
% 运行所有试验的神经网络模型。
%
% Yao Wang, 2024年3月30日, 天津大学。
% *************************************************************************

% 为随机数生成器设置种子。
rng(5); % 这可以确保结果的可重复性。

figurePath = './'; % 图片保存路径
LABEL_SIZE = 22; % 标签文本大小
TITLE_SIZE = 22; % 标题文本大小

% 开始模拟神经网络。
nTrial = 130; % 试验次数

% 设置电流正态分布标准差参数
std = 0.00:0.02:0.2; 
n_std = length(std); 
simd   = [1, 1.3, 1.6, 1.8, 2.7, 4];

accur = zeros(1, n_std);
computation_time = zeros(1, n_std);

for i = 1:n_std
% 调用神经网络上下文学习函数，返回多个相关结果参数

tic;
[PerCorrect, FiringRate, FIndex, W12perTrial, W23perTrial, RasterPlot] = ...
    spikingNetworkContextLearning(std(i));
computation_time(i) = toc;
% [nTrial, nStim, nHippo] = size(FiringRate); % 获取返回结果的维度信息
accur(i) = sum(PerCorrect) / nTrial * 100;
fprintf('Overall percent correct trials: %2.2f.\n', accur(i));
end

figure;
subplot(2,1,1);
plot(std, accur, '-o', 'LineWidth', 1.5);
xlabel('Standard Deviation', 'FontSize', LABEL_SIZE);
ylabel('Accuracy', 'FontSize', LABEL_SIZE);
title('Accuracy vs. Standard Deviation', 'FontSize', TITLE_SIZE);
yline(accur(1), '--', 'Color', 'r', 'LineWidth', 1.5);
legend('Accuracy', 'Baseline', 'Location', 'best');
grid on;

subplot(2,1,2);
plot(std, computation_time, '-c', 'LineWidth', 1.5);
xlabel('Standard Deviation', 'FontSize', LABEL_SIZE);
ylabel('Computation Time (seconds)', 'FontSize', LABEL_SIZE);
title('Effect of Standard Deviation on Computation Time', 'FontSize', TITLE_SIZE);
yline(computation_time(1), '--', 'Color', 'r', 'LineWidth', 1.5);
legend('computation_time', 'Original', 'Location', 'best');
grid on;

hold on;
set(gca, 'FontName', 'Times New Roman'); % 将文字字体设置为 Times New Roman
hold off;


% 打印正确试验的百分率。
% fprintf('Overall percent correct trials: %2.2f.\n', sum(PerCorrect) / nTrial * 100);

% % *************************************************************************
% % 绘制正确试验百分比的轨迹图。
% % *************************************************************************
% TrialWindow = repmat(1/30, [30, 1]); % 创建平滑窗口
% PerCorrect = imfilter(double(PerCorrect), TrialWindow, 'same', 0) * 100; % 使用平滑窗口过滤数据进行平滑
% TrialIndex = 30:(nTrial-30); % 定义用于绘图的试验指数窗口
% PerCorrect = PerCorrect(TrialIndex); % 获取该窗口内的数据作为绘图数据
% 
% figure('Name', 'Figure_test', 'NumberTitle', 'off'); % 创建图像窗口
% plot(TrialIndex, PerCorrect, '-k', 'LineWidth', 1.5); % 绘制平滑后的正确率变化曲线
% xlabel('Sliding 30 Trial Window', 'FontSize', LABEL_SIZE); % x轴标签及其文字大小
% ylabel('Performance (Percent Correct)', 'FontSize', LABEL_SIZE); % y轴标签及其文字大小
% set(gca, 'FontSize', LABEL_SIZE); % 设置坐标轴文字大小
% axis([30, nTrial-30, 0, 110]); % 设置坐标轴范围
% print('-deps', sprintf('%sFigure_test.eps', figurePath)); % 打印并保存图像


