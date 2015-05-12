function fm = fm_docs_init(KK,aa,q0,docs,docs_zz);
% initialize finite mixture model, with 
% KK mixture components,
% aa concentration parameter,
% q0 an empty component with hh prior,
% xx data, x_i=xx{i}
% zz initial cluster assignments (between 1 and KK).

fm.KK = KK;
fm.NN = length(docs);
fm.qq = cell(1,KK);
fm.aa = aa;

for dd = 1 : fm.NN
    doc.xx = docs{dd};
    doc.zz = docs_zz{dd};
    doc.nn = zeros(1,KK);
    docs{dd} = doc;
end
fm.docs = docs;

% initialize mixture components
for kk = 1:KK,
  fm.qq{kk} = q0.copy;
end

% add data items into mixture components
for ii = 1:fm.NN
    doc = fm.docs{ii};
    for jj = 1:length(doc.xx)
      kk = doc.zz(jj);
      additem(fm.qq{kk},doc.xx(jj));
      doc.nn(kk) = doc.nn(kk) + 1;
    end
    fm.docs{ii} = doc;
end