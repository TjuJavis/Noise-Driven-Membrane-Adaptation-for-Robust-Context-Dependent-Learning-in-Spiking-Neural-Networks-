function [ha, hl] = errorarea(X, MeanValue, StdValue, colorArea, colorLine)
% errorarea
%   X           - 水平轴坐标。
%   MeanValue   - 均值数据。
%   StdValue    - 标准差数据。
%   colorArea   - 用于覆盖 ±1个标准差区域的颜色。
%   colorLine   - 用于显示均值线的颜色。
%
% 返回
%   ha          - 区域的句柄。
%   hl          - 线条的句柄。
%
% 描述
%   在指定的水平轴上绘制均值和标准差区域。这个函数主要用于数据的可视化，
%   特别是在展示统计数据的平均值和变异性时。
%
%   Florian Raudies, 09/07/2014, Boston University.

% 设置默认颜色，如果函数调用时没有指定颜色
if nargin < 4, colorArea = 'b'; end % 如果没有指定区域颜色，默认为蓝色
if nargin < 5, colorLine = 'k'; end % 如果没有指定线条颜色，默认为黑色

% 准备绘制区域的数据
Xd = [X(:); flipud(X(:))]; % 创建一个扩展的X坐标数组，用于绘制上下标准差区域
% 创建一个Y坐标数组，包含均值加减标准差的值
Yd = [MeanValue(:) - StdValue(:); flipud(MeanValue(:) + StdValue(:))]; 

% 绘制标准差区域
ha = fill(Xd, Yd, colorArea, 'LineStyle', 'none'); % 使用fill函数填充标准差区域
hold on; % 保持当前图形，以便在其上继续绘制

% 绘制均值线
hl = plot(X(:), MeanValue(:), '-', 'LineWidth', 2.0, 'Color', colorLine); % 绘制表示均值的线条
hold off; % 完成绘图

% 这个函数的输出包括两个句柄：`ha` 为填充区域的句柄，`hl` 为均值线的句柄。
% 这使得调用者可以在函数外部进一步自定义或操作这些图形元素。
% 例如，可以调整线条的样式、区域的透明度等。
% 此函数对于生成科学报告或演示文稿中的图形非常实用，
% 特别是当需要直观地展示数据的平均值和其变异范围时。
