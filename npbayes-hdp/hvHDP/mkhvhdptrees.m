function [tnodes] = mkhvhdptrees(hdps,jsonfile)




tnodes = '';

docOffset = 0;
for i=1:length(hdps)
    hdp = hdps{i};
    topicOffset = docOffset+hdp.numdp-1;
    for j=1:length(hdp.dp)
        dp = hdp.dp{j};
        if isempty(dp.datass)
            continue;
        end
        beta = dp.beta;
        ind = find(beta>0.01);
        for jj = 1:length(ind)
            node = struct('src',ind(jj)+topicOffset,'dst',docOffset+j-1, 'value', beta(ind(jj)));
            tnodes{length(tnodes)+1}=node;
        end
    end
    docOffset = docOffset+hdp.numdp-1;
end

if exist('jsonfile','var')
    savejson('hvtree',tnodes,jsonfile);
end