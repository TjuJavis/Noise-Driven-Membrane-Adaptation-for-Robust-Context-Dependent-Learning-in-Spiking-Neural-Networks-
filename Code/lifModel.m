function V = lifModel(~, V, opt)
% lifModel
%   t   - 毫秒单位的时间。
%   V   - 电压值，单位是伏特。
%   opt - 包含字段的结构体：
%         * dt      - 模拟每步的时间，单位是毫秒。
%         * V_PEAK  - 电压峰值，单位是伏特。
%         * V_RESET - 电压复位值，单位是伏特。
%         * V_TH    - 触发动作电位的阈值电压，单位是伏特。
%
% RETURN
%   V   - 更新后的电压值，单位是伏特。
%
% DESCRIPTION
%   漏电整流和放电（Leaky Integrate and Fire，LIF）模型。

%   Florian Raudies, 09/07/2014, Boston University.

dt          = opt.dt;       % 步长，单位为毫秒
V_PEAK      = opt.V_PEAK;   % 电压峰值，单位为伏特。
V_RESET     = opt.V_RESET;  % 电压复位值，单位为伏特。
V_TH        = opt.V_TH;     % 动作电位阈值，单位为伏特。
C_MEM       = 5.5;          % 膜电容，单位为纳法拉德。
G_LEAK      = 10;           % 膜泄漏电导，单位为纳西门斯。
% tau=1.8;
% R_LEAK=0.18;


% 膜时间常数tau = G_LEAK / C_MEM

% 电压是否达到峰值或以上？
AbovePeak   = V >= V_PEAK;

% 如果电压达到峰值或以上，则进行复位。
V(AbovePeak) = V_RESET;

% 电压是否达到阈值以上？
AboveTh     = V > V_TH;

% 如果电压达到阈值以上，则设置为峰值。
V(AboveTh)  = V_PEAK;

% 通过使用LIF（Leaky Integrate-and-Fire）方程，更新到目前为止尚未更新的所有膜电位。
% LIF方程描述了神经元膜电位的变化，其中包括漏电流和输入电流的影响。

% Update表示当前膜电位尚未达到峰值且尚未超过阈值的神经元。
Update      = ~AbovePeak & ~AboveTh;

% 对于所有未达到峰值且未超过阈值的神经元，根据LIF方程进行更新。
% V表示膜电位，dt表示时间步长，G_LEAK表示漏电导，C_MEM表示膜电容，
% V_RESET表示重置膜电位，opt.I表示输入电流。
V(Update)   = V(Update) + dt * 10^-3 * (G_LEAK/C_MEM * (V_RESET - V(Update)) ...
                                        + opt.I(Update)/C_MEM);
% V(Update)   = V(Update) * (1 - dt * 10^-3 / tau) + dt * 10^-3 / tau * R_LEAK * opt.I(Update);

