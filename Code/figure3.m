clc % 清除命令窗口
clear % 清除所有变量
close all % 关闭所有图窗

% *************************************************************************
% 复现图3。
% nTrial
% 运行所有试验的神经网络模型。
%
% Wang Yao, 2024年1月29日, 天津大学。
% *************************************************************************

% 定义试验间隔时间，以毫秒为单位
IntvlTrial  = [0 4000]; % ms，表示试验持续时间从0到4000毫秒
IntvlReplay = [0 400];  % ms，表示复现(replay)过程的时间从0到400毫秒

% 时间步长，模拟过程中每一步的时间间隔
dt          = 0.5;      % time step，时间步长为0.5毫秒

% 根据间隔和时间步长生成时间点
TimeTrial   = ( IntvlTrial(1)  : dt : IntvlTrial(2)  )'; % 生成试验过程的时间点

% 计算时间点的数量
nTimeTrial  = length(TimeTrial);    % 试验时间点的数量
NoiseV1     = 1*10^-6*randn(nTimeTrial, 1);  % 生成随机数列


% 初始化图形参数
TITLE_SIZE     = 22; % 标题文本大小
LABEL_SIZE     = 22; % 标签文字大小
AXIS_FONT_SIZE = 22; % 坐标轴文字大小
figurePath     = './'; % 确保这是一个有效的路径

% 绘制随机数列
figure('Name', 'Figure 3', 'Units', 'Inches', 'Position', [0, 0, 8, 6], 'NumberTitle', 'off');
plot(1:nTimeTrial, NoiseV1);


% 调整坐标轴标签和标题
title('Visualization of Noise', 'FontSize', TITLE_SIZE, 'FontWeight', 'bold');
xlabel('Noise Floor', 'FontSize', LABEL_SIZE, 'FontWeight', 'bold');
ylabel('Value', 'FontSize', LABEL_SIZE, 'FontWeight', 'bold');

% 设置坐标轴文字大小和坐标轴范围
set(gca, 'FontSize', AXIS_FONT_SIZE, 'FontWeight', 'bold', 'LineWidth', 1);
axis([0, 8000, -5*10^-6, 5*10^-6]);
set(gca, 'FontName', 'Times New Roman'); % 将文字字体设置为 Times New Roman


% 将图像保存为矢量图格式，适合发表质量要求较高的文章
set(gcf, 'PaperPositionMode', 'auto');
print('-depsc', sprintf('%sFigure3.eps', figurePath)); % 保存为EPS格式
