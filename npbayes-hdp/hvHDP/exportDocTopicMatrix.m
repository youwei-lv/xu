function [m]= ExportDocTopicMatrix(hdp_sample,dpidx)
    kk = hdp_sample.numclass;
    dd = length(dpidx);
    m = zeros(dd,kk);
    for idd = 1:dd
        m(idd,:) = hdp_sample.beta{dpidx(idd)};
    end
end