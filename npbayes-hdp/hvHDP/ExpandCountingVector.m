function [v] = ExpandCountingVector(count)
    v = [];
    idx = find(count > 0);
    for i=1:length(idx)
        v = [v,ones(1,count(idx(i)))*idx(i)];
    end
end