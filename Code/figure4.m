clc % 清除命令窗口
clear % 清除所有变量
close all % 关闭所有图窗

% *************************************************************************
% 复现图4。
% nTrial
% 运行所有试验的神经网络模型。
%
% Wang Yao, 2024年1月29日, 天津大学。
% *************************************************************************

% 为随机数生成器设置种子。
rng(5); % 这可以确保结果的可重复性。

% 开始模拟神经网络。
nTrial = 130; % 试验次数

simd   = 1;
tau    = 2;
Am     = 1;

% 调用神经网络上下文学习函数，返回多个相关结果参数
[PerCorrect, FiringRate, FIndex, W12perTrial, W23perTrial, RasterPlot] = ...
    spikingNetworkContextLearning(nTrial, simd, tau, Am, 1);

% 打印正确试验的百分率。
fprintf('Overall percent correct trials: %2.2f.\n', sum(PerCorrect) / nTrial * 100);

% *************************************************************************
% 绘制正确试验百分比的轨迹图。
% *************************************************************************
% 初始化图形参数
LABEL_SIZE     = 22; % 标签文字大小
AXIS_FONT_SIZE = 22; % 坐标轴文字大小
LINE_WIDTH     = 2; % 曲线线宽
figurePath     = './'; % 确保这是一个有效的路径
nTrial         = numel(PerCorrect); 

TrialWindow = repmat(1/30, [30, 1]); % 创建平滑窗口
PerCorrect  = imfilter(double(PerCorrect), TrialWindow, 'same', 0) * 100; % 使用平滑窗口过滤数据进行平滑

TrialIndex = 30:(nTrial-30); % 定义用于绘图的试验指数窗口
PerCorrect = PerCorrect(TrialIndex); % 获取该窗口内的数据作为绘图数据

% 创建图像窗口
figure('Name', 'Figure 4', 'Units', 'Inches', 'Position', [0, 0, 8, 6], 'NumberTitle', 'off');
hold on; box on; grid on; % 开启网格和边框，保持绘制状态

% 绘制平滑后的正确率变化曲线
plot(TrialIndex, PerCorrect, '-k', 'LineWidth', LINE_WIDTH);

% 调整坐标轴标签和标题
xlabel('Trial Number', 'FontSize', LABEL_SIZE, 'FontWeight', 'bold');
ylabel('Performance (Percent Correct)', 'FontSize', LABEL_SIZE, 'FontWeight', 'bold');

% 设置坐标轴文字大小和坐标轴范围
set(gca, 'FontSize', AXIS_FONT_SIZE, 'FontWeight', 'bold', 'LineWidth', 1.2);
axis([30, nTrial-30, 0, 110]);
set(gca, 'FontName', 'Times New Roman'); % 将文字字体设置为 Times New Roman

% 将图像保存为矢量图格式，适合发表质量要求较高的文章
set(gcf, 'PaperPositionMode', 'auto');
print('-depsc', sprintf('%sFigure4.eps', figurePath)); % 保存为EPS格式
hold off;

