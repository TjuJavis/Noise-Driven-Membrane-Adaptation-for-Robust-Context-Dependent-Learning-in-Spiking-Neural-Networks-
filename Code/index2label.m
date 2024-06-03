function Label = index2label(index)
% index2label
%   index   - 从1到8的线性索引。
% 
% RETURN
%   Label   - 标签字符串。
%
% DESCRIPTION
%   将线性索引映射到包含上下文、位置和刺激的标签，使用以下分配：
%
%   index | label
%   -------------
%   1     | A1X
%   2     | B1X
%   3     | A2X
%   4     | B2X
%   5     | A1Y
%   6     | B1Y
%   7     | A2Y
%   8     | B2Y
%   -----------

%   Florian Raudies, 09/07/2014, Boston University.

switch index
    case 1, Label = 'A1X';
    case 2, Label = 'B1X';
    case 3, Label = 'A2X';
    case 4, Label = 'B2X';
    case 5, Label = 'A1Y';
    case 6, Label = 'B1Y';
    case 7, Label = 'A2Y';
    case 8, Label = 'B2Y';
    otherwise, Label = 'unknown';
end
