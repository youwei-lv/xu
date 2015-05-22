function [outputs] = MakeResults(hdpTree, vobList)

outputs = cell(1,length(hdpTree));
for i = 1:length(hdpTree)
    hdp_sample = hdpTree{i};
    sortedTopicWord = ExportSortedTopicWords(vobList, hdp_sample, 200);
    docTopicMatrix= ExportDocTopicMatrix(hdp_sample,2:length(hdp_sample.datacc));
    outputs{i}.sortedTopicWord = sortedTopicWord;
    outputs{i}.docTopicMatrix = docTopicMatrix;
    outputs{i}.hdp_sample = hdp_sample;
end