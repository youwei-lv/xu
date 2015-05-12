function [tt,ttww] = showHDPs(hdps,vobs)

tt = '';
ttww = '';
for i=1:length(hdps)
    hdp = hdps{i};
    tp = cell(hdp.base.numclass,1);
    tw = cell(hdp.base.numclass,1);
    for j =1:hdp.base.numclass
      [tp{j}, I]= sort(hdp.base.classqq(:,j),1,'descend');
      tw{j} = vobs(I);
    end
    tt{length(tt)+1}=tp;
    ttww{length(ttww)+1} = tw;
end


end