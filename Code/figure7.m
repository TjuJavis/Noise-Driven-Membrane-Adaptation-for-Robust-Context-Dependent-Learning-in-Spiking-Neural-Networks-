clc % 清除命令窗口
clear % 清除所有变量
close all % 关闭所有图窗

% 为随机数生成器设置种子。
rng(5); % 这可以确保结果的可重复性。

% 开始模拟神经网络。
nTrial = 130; % 试验次数

simd   = 2;
tau    = 2;
Am     = 1;

for i = 1:2     %开始循环
    rng(5); % 这可以确保结果的可重复性。
    % 调用神经网络上下文学习函数，返回多个相关结果参数
    [PerCorrect, ~, ~, ~, ~, ~] = ...
        spikingNetworkContextLearning(nTrial, simd, tau, Am, i);
    Overallpercentcorrect(i) = sum(PerCorrect) / nTrial * 100;
    overalPerCorrect(i,:)    = PerCorrect;
    % 打印正确试验的百分率。
    fprintf('Overall percent correct trials: %2.2f.\n', Overallpercentcorrect(i));
end

% 初始化图形参数
TITLE_SIZE     = 22; % 标题文本大小
LABEL_SIZE     = 22; % 标签文字大小
AXIS_FONT_SIZE = 22; % 坐标轴文字大小
LINE_WIDTH     = 2; % 曲线线宽
figurePath     = './'; % 确保这是一个有效的路径
nTrial         = numel(PerCorrect); % 假设PerCorrect已经被定义
TrialWindow    = repmat(1/30, [1, 30]); % 创建平滑窗口
TrialIndex     = 30:(nTrial-30); % 定义用于绘图的试验指数窗口
% *************************************************************************
% 绘制正确试验百分比的轨迹图。
% *************************************************************************
for i=1:2
    overalPerCorrect(i,:)  = imfilter(double(overalPerCorrect(i,:)), TrialWindow, 'same', 0) * 100; % 使用平滑窗口过滤数据进行平滑
    ToveralPerCorrect(i,:) = overalPerCorrect(i,TrialIndex); % 获取该窗口内的数据作为绘图数据
end
% 创建图像窗口
figure('Name', 'Figure 7', 'Units', 'Inches', 'Position', [0, 0, 8, 6], 'NumberTitle', 'off');
hold on; box on; grid on; % 开启网格和边框，保持绘制状态

% 绘制平滑后的正确率变化曲线
plot(TrialIndex, ToveralPerCorrect(1,:), '-m', 'LineWidth', LINE_WIDTH);
plot(TrialIndex, ToveralPerCorrect(2,:), '-c', 'LineWidth', LINE_WIDTH);

% 调整坐标轴标签和标题
xlabel('Trial Number', 'FontSize', LABEL_SIZE, 'FontWeight', 'bold');
ylabel('Performance (Percent Correct)', 'FontSize', LABEL_SIZE, 'FontWeight', 'bold');
legend('Use NALIF ','Not Use ', 'Location', 'southeast')

% 设置坐标轴文字大小和坐标轴范围
set(gca, 'FontSize', AXIS_FONT_SIZE, 'FontWeight', 'bold', 'LineWidth', 1.2);
axis([30, nTrial-30, 0, 110]);
set(gca, 'FontName', 'Times New Roman'); % 将文字字体设置为 Times New Roman

% 将图像保存为矢量图格式，适合发表质量要求较高的文章
set(gcf, 'PaperPositionMode', 'auto');
print('-depsc', sprintf('%sFigure7.eps', figurePath)); % 保存为EPS格式
hold off;
