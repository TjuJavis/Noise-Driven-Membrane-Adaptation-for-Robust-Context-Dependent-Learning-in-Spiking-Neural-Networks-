clc; % 清除命令窗口
clear; % 清除所有变量
close all; % 关闭所有图窗

% *************************************************************************
% 复现图11。
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
std = 0.00:0.02:0.06; 
n_std = length(std); 
simd   = 1:0.04:1.12;

accur = zeros(length(simd), length(std));
computation_time = zeros(length(simd), length(std));

for i = 1:length(std)
    for j = 1:length(simd)
        % 调用神经网络上下文学习函数，返回多个相关结果参数
        tic;
        [PerCorrect, FiringRate, FIndex, W12perTrial, W23perTrial, RasterPlot] = ...
            spikingNetworkContextLearning(std(i), simd(j));
        computation_time(j, i) = toc;
        accur(j, i) = sum(PerCorrect) / nTrial * 100;
        fprintf('Overall percent correct trials: %2.2f.\n', accur(j, i));
    end
end

[stdGrid, simdGrid] = meshgrid(std, simd); % 创建网格

% 绘制三维图像
figure;
surf(stdGrid, simdGrid, accur, 'EdgeColor', 'none');
xlabel('Standard Deviation', 'FontSize', LABEL_SIZE);
ylabel('Noise', 'FontSize', LABEL_SIZE);
zlabel('Accuracy', 'FontSize', LABEL_SIZE);
title('Relationship between Standard Deviation, Noise, and Accuracy', 'FontSize', TITLE_SIZE);
hold on; % 保持图像

% 创建 xy 平面
zBase = ones(size(stdGrid)) * accur(1, 1); % 设置 z 值为 accur 的第一个元素
surf(stdGrid, simdGrid, zBase, 'FaceColor', 'r', 'FaceAlpha', 0.3); % 设置红色透明面

grid on;

% 将图像保存为矢量图格式，适合发表质量要求较高的文章+
set(gcf, 'PaperPositionMode', 'auto');
print('-depsc', sprintf('%sFigure11.eps', figurePath)); % 保存为EPS格式
hold off;
