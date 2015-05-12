function [docs, vobsize] = readId2NumFile(filename)
docs = '';
vobsize = 0;

fid = fopen(filename);
tline = fgetl(fid);
while ischar(tline)
    id2nums = sscanf(tline,'%d:%d,');
    id2nums = reshape(id2nums,2,length(id2nums)/2);
    d = [];
    for j = 1:size(id2nums,2)
        if id2nums(1,j) == 0
            continue;
        end
        d = [d,ones(1,id2nums(2,j))*id2nums(1,j)];
    end
    if vobsize < max(d)
        vobsize = max(d);
    end
    docs{length(docs)+1} = num2cell(d);
    tline = fgetl(fid);
end
fclose(fid);
end