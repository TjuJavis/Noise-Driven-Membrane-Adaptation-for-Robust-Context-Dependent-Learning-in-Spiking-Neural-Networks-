classdef StackContainer < handle
    % StackContainer - 实现带有许多槽位和每个槽位最大条目数量的堆栈容器。
    
    % Florian Raudies, 09/07/2014, 波士顿大学。
    
    properties
        nSlot       % 槽位数量。
        nMaxEntry   % 每个槽位的最大条目数量。
        Counter     % 每个槽位的计数器，跟踪每个槽位中的条目数量。
        Container   % 存储数据的缓冲区。
    end
    
    methods
        % 构造函数。
        function obj = StackContainer(varargin)
            % nSlot, nMaxEntry
            if numel(varargin) == 2
                obj.nSlot       = varargin{1};
                obj.nMaxEntry   = varargin{2};
                obj.Counter     = zeros(obj.nSlot, 1);
                obj.Container   = zeros(obj.nSlot, obj.nMaxEntry);
            else
                obj.nSlot       = 0;
                obj.nMaxEntry   = 0;
                obj.Counter     = 0;
                obj.Container   = 0;
            end                
        end
        
        % 不适用于对象句柄，因为它需要某种形式的递归。
        % 如果存在指向此对象的循环指针，则这也是有问题的。
        function new = copy(obj)
            % 实例化相同类别的新对象。
            new = feval(class(obj)); 
            % 复制所有非隐藏属性。
            p = properties(obj);
            for i = 1:length(p)
                new.(p{i}) = obj.(p{i});
            end
        end
        
        function e = numel(obj, iSlot)
            % 返回指定槽位中的条目数量。
            e = obj.Counter(iSlot);
        end
        
        function b = empty(obj, iSlot)
            % 检查指定槽位是否为空。
            b = obj.Counter(iSlot) == 0;
        end
        
        function obj = push(obj, iSlot, data)
            % 将数据推送到指定槽位的堆栈中。
            if obj.Counter(iSlot) == obj.nMaxEntry
                error('StackContainer:CapacityLimit', 'Full!');
            end
            obj.Counter(iSlot) = obj.Counter(iSlot) + 1;
            obj.Container(iSlot, obj.Counter(iSlot)) = data;
        end
        
        function data = pop(obj, iSlot)
            % 从指定槽位的堆栈中弹出数据。
            if obj.Counter(iSlot) == 0
                error('StackContainer:CapacityLimit', 'Empty!');
            end            
            data = obj.Container(iSlot, obj.Counter(iSlot));
            obj.Counter(iSlot) = obj.Counter(iSlot) - 1;
        end        
    end
end
