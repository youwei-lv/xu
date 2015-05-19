function fm = lda_init(KK,aa,vobsize,eta,docs,docs_zz)
% initialize finite mixture model, with 
% KK mixture components,
% aa concentration parameter,
% q0 an empty component with hh prior,
% xx data, x_i=xx{i}
% zz initial cluster assignments (between 1 and KK).

fm.KK = KK;
fm.NN = length(docs);
fm.aa = aa;
qq.mm = zeros(KK,vobsize);
qq.sc = zeros(1,KK);
qq.eta = eta;

for dd = 1 : fm.NN
    doc.xx = docs{dd};
    doc.zz = docs_zz{dd};
    doc.nn = zeros(1,KK);
    docs{dd} = doc;
end

fm.docs = docs;

% add data items into mixture components
for ii = 1:fm.NN
    doc = fm.docs{ii};
    for jj = 1:length(doc.xx)
      kk = doc.zz(jj);
      qq.mm(kk,doc.xx{jj}) = qq.mm(kk,doc.xx{jj}) + 1;
      qq.sc(kk) = qq.sc(kk) + 1;
      doc.nn(kk) = doc.nn(kk) + 1;
    end
    fm.docs{ii} = doc;
end

fm.qq = qq;