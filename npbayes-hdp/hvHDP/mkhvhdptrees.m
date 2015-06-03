function [tnodes] = mkhvhdptrees(treeResult,jsonfile,topicWordFile)

% write jsonfile
docOffset = 0;
jsonNodes = '';

for i=1:length(treeResult)
    docTopicMatrix = treeResult{i}.docTopicMatrix;
    numdoc = size(docTopicMatrix,1);
    
    topicOffset = docOffset + size(docTopicMatrix,1);
    for dd = 1:numdoc
        dkk = find(docTopicMatrix(dd,:)>0.01);
        for jj = 1:length(dkk)
            node = struct('src',dd+docOffset,'dst',dkk(jj)+topicOffset,'value',docTopicMatrix(dd,dkk(jj)));
            jsonNodes{length(jsonNodes)+1} = node;
        end
    end
    docOffset = topicOffset;
end

if exist('jsonfile','var')
    savejson('hvtree',jsonNodes,jsonfile);
end

% output topic files

twfid = fopen(topicWordFile, 'w+');

docTopicMatrix = treeResult{1}.docTopicMatrix;
topicOffset = size(docTopicMatrix,1);

for i=1:length(treeResult)
    soredTopicWord = treeResult{i}.sortedTopicWord;
    for jj = 1:size(soredTopicWord,1)
        fprintf(twfid,'%d: ',jj+topicOffset);
        for kk = 1:size(soredTopicWord,2)
            fprintf(twfid, '%s\t', soredTopicWord{jj,kk});
        end
        fprintf(twfid,'\n');
    end
    topicOffset = topicOffset + size(soredTopicWord,1); 
end

fclose(twfid);
