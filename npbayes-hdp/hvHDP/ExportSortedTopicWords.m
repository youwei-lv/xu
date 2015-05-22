function [wmat]= ExportSortedTopicWords(vobList, hdp_sample, numword)
    kk = hdp_sample.numclass;
    wmat = cell(kk,numword);
    for ikk = 1:kk
        [~,I] = sort(hdp_sample.classqq(:,ikk),'descend');
        for iww = 1:numword
            wmat{ikk,iww} = vobList{I(iww)};
        end
    end
end