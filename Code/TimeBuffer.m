classdef TimeBuffer < handle
    % TimeBuffer - 单一缓冲区用于存储时间戳。retire方法删除所有早于t-nHistory的条目。
    
    %   Florian Raudies, 09/07/2014, 波士顿大学.
    
    properties
        nEntry      % 条目数量。
        nBuffer     % 缓冲区数量。
        nHistory    % 回溯的步数。
        Counter     % 每个缓冲区的计数器。
        Buffer      % 存储时间值的缓冲区。
    end
    
    methods
        % 构造函数。
        function obj = TimeBuffer(nEntry, nBuffer, nHistory)
            % 创建一个TimeBuffer实例。
            % 参数：
            %   nEntry: 条目数量
            %   nBuffer: 缓冲区数量
            %   nHistory: 回溯的步数
            obj.nEntry      = nEntry;
            obj.nBuffer     = nBuffer;
            obj.nHistory    = nHistory;
            obj.Counter     = zeros(nBuffer, 1);
            obj.Buffer      = zeros(nEntry, nBuffer);
        end
        
        function obj = clear(obj)
            % 清空缓冲区。
            obj.Counter = zeros(obj.nBuffer, 1);
            obj.Buffer  = zeros(obj.nEntry, obj.nBuffer);
        end
        
        % 退休条目。
        function obj = retire(obj, time)
            % 删除所有早于t-nHistory的条目。
            for iBuffer = 1:obj.nBuffer
                % 如果缓冲区为空，跳过。
                if obj.Counter(iBuffer) == 0, continue; end
                % 找到需要删除的条目。
                ToRetire = obj.Buffer(1:obj.Counter(iBuffer), iBuffer) < time - obj.nHistory;
                % 如果没有需要删除的条目，跳过。
                if sum(ToRetire) == 0, continue; end
                % 获取保留的条目的索引。
                Index = sum(ToRetire) + 1 : obj.Counter(iBuffer);
                % 如果Index为空，将计数器置为零。
                if isempty(Index), obj.Counter(iBuffer) = 0; continue; end
                % 将保留的条目复制到缓冲区的前部。
                obj.Buffer(1:length(Index), iBuffer) = obj.Buffer(Index, iBuffer);
                % 更新计数器。
                obj.Counter(iBuffer) = length(Index);
            end
        end
        
        % 添加时间。
        function obj = addTime(obj, time, ToBuffer)
            % 添加时间戳到缓冲区。
            % 参数：
            %   time: 时间戳
            %   ToBuffer: 要添加到的缓冲区的逻辑向量
            if any(ToBuffer)
                for iToBuffer = find(ToBuffer)
                    % 将时间戳添加到缓冲区。
                    obj.Buffer(1 + obj.Counter(iToBuffer), iToBuffer) = time;
                    % 更新计数器。
                    obj.Counter(iToBuffer) = obj.Counter(iToBuffer) + 1;
                end
            end
        end
        
        % 为iBuffer检索时间。
        function Time = time(obj, iBuffer)
            % 返回指定缓冲区的时间戳。
            Time = obj.Buffer(1:obj.Counter(iBuffer), iBuffer);
        end
        
        % 打印缓冲区的内容。
        function print(obj)
            for iBuffer = 1:obj.nBuffer
                fprintf('buffer %d: ', iBuffer);
                for iEntry = 1:obj.Counter(iBuffer)
                    fprintf('%d, ', obj.Buffer(iEntry, iBuffer));
                end
                fprintf('\n');
            end            
        end
    end
end
