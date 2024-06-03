classdef ManySlotBuffer < handle
    % ManySlotBuffer - 具有nSlot槽位的缓冲区。
    
    % Florian Raudies, 09/07/2014, Boston University.
    
    properties
        nSlot       % 槽位数量。
        nEntry      % 每个槽位的最大条目数量。
        nData       % 数据的维度数量。
        Counter     % 每个缓冲区的计数器，跟踪每个槽位中的条目数量。
        Buffer      % 存储数据的缓冲区，以三维矩阵形式表示。
    end
    
    methods
        % 构造函数。
        function obj = ManySlotBuffer(nSlot, nEntry, nData)
            % ManySlotBuffer构造函数，初始化缓冲区属性。
            %   nSlot  - 槽位数量。
            %   nEntry - 每个槽位的最大条目数量。
            %   nData  - 数据的维度数量。
            obj.nSlot       = nSlot;
            obj.nEntry      = nEntry;
            obj.nData       = nData;
            obj.Counter     = zeros(nSlot, 1);  % 初始化计数器为零。
            obj.Buffer      = zeros(nSlot, nEntry, nData);  % 初始化缓冲区为零矩阵。
        end
        
        function obj = clear(obj)
            % 清空缓冲区的方法，将计数器和缓冲区重置为零。
            obj.Counter = zeros(obj.nSlot, 1);
            obj.Buffer  = zeros(obj.nSlot, obj.nEntry, obj.nData);
        end
        
        function obj = addEntryToSlot(obj, iSlot, Data)
            % 将数据条目添加到指定槽位的方法。
            %   iSlot - 要添加条目的槽位索引。
            %   Data  - 要添加的数据。
            obj.Counter(iSlot) = obj.Counter(iSlot) + 1;  % 计数器加一。
            % 在缓冲区中的指定位置存储数据。
            obj.Buffer(iSlot, obj.Counter(iSlot), 1:numel(Data)) = Data;
        end
        
        function Data = getAllEntryForSlot(obj, iSlot)
            % 获取指定槽位中的所有条目的方法。
            %   iSlot - 要获取条目的槽位索引。
            %   Data  - 返回指定槽位中的所有数据条目。
            Data = squeeze(obj.Buffer(iSlot, 1:obj.Counter(iSlot), :));            
        end
    end
end
