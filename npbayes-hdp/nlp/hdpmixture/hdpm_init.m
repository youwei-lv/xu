function hdpm = hdpm_init(KK,aa_0,q0,docs,docs_zz,aa_1);
% initialize finite mixture model, with 
% KK mixture components,
% aa concentration parameter,
% q0 an empty component with hh prior,
% xx data, x_i=xx{i}
% zz initial cluster assignments (between 1 and KK).

%hdpm.KK = KK;
hdpm.NN = length(docs);
hdpm.qq = cell(1,KK+1); % global component handles
hdpm.nn = zeros(1,KK);  % counts of tables in the global

hdpm.aa_0 = aa_0;
hdpm.aa_1 = aa_1;

dps = cell(1,length(docs));

% initialize mixture components
for kk = 1:KK+1,
  hdpm.qq{kk} = q0.copy;
  hdpm.qq{kk}.id = kk;
end

for dd = 1 : hdpm.NN
    dp.xx = docs{dd};     % data in a doc
    dp.numdata = length(docs{dd});
    dp.zz = docs_zz{dd};  % component nos in dp
    dp.tt = ones(1,length(dp.xx)); % table no in the component tables, set to 1
    dps{dd} = dp;
    % increase global number of tables by one
    hdpm.nn(unique(dp.zz)) = hdpm.nn(unique(dp.zz)) + 1; 
end

hdpm.dps = dps;

gidx = hdpm.nn == 0;
hdpm.qq(gidx) = '';
hdpm.nn(gidx) = '';
hdpm.KK = sum(~gidx); % globally active components

% add data items into mixture components
for ii = 1:hdpm.NN
    dp = hdpm.dps{ii};
    dp.zz = relabel(dp.zz, find(~gidx),1:hdpm.KK);
    dp.nn = zeros(1,hdpm.KK);  % counts of components in dp
    dp.qq_ref = hdpm.qq;
    for jj = 1:length(dp.xx)
      kk = dp.zz(jj);
      additem(hdpm.qq{kk},dp.xx{jj});
      dp.nn(kk) = dp.nn(kk) + 1;
    end
    
    idx = dp.nn > 0;
    dp.zz = relabel(dp.zz, find(idx), 1:sum(idx)); % relabel the component no in dp
    dp.nn = dp.nn(idx); % remove counts of zeros
    dp.tt_n = num2cell(dp.nn); % data counts in each tables serving the same dish
    dp.qq_ref = hdpm.qq(logical([idx,1]));   % update component handlers with the prior preserved
    dp.KK = length(dp.nn);
    hdpm.dps{ii} = dp;
end

end

function [v] = relabel(v, old_label, new_label)
    idx = true(1, length(v));
    for i = 1:length(old_label)
        idx = ((v==old_label(i)) & idx);
        v(idx) = new_label(i);
        idx = ~idx;
    end
end