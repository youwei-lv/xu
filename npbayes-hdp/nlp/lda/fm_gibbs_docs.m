function [fm, sample] = fm_gibbs_docs(fm,numiter)
% run numiter number of iterations of gibbs sampling in the finite mixture

KK = fm.KK;
NN = fm.NN;
aa = fm.aa;
qq = fm.qq;
%xx = fm.xx;
%zz = fm.zz;

docs = fm.docs;

sample = cell(1,numiter);

for iter = 1:numiter
    ss = cell(1,NN);
    % in each iteration, remove each data item from model, then add it back in.
    for dd = 1 : NN
        doc = docs{dd};
        nn = doc.nn;
        zz = doc.zz;
        xx = doc.xx;
        for ii = 1:length(xx)
            % remove data item xx{ii} from component qq{kk}
            kk = doc.zz(ii);
            nn(kk) = nn(kk) - 1;
            delitem(qq{kk},xx(ii));
            
            % compute probabilities pp(kk) of each component kk
            pp = log(aa/KK + nn);
            for kk = 1:KK
                pp(kk) = pp(kk) + logpredictive(qq{kk},xx(ii));
            end
            pp = exp(pp - max(pp));
            pp = pp / sum(pp);
            
            % choose component kk
            uu = rand;
            kk = 1+sum(uu>cumsum(pp));
            
            % add data item xx{ii} back into model (component qq{kk})
            zz(ii) = kk;
            nn(kk) = nn(kk) + 1;
            additem(qq{kk},xx(ii));
        end
        doc.nn = nn;
        doc.zz = zz;
        docs{dd} = doc;
        ss{dd} = zz;
    end
    sample{iter} = ss;
end

fm.docs = docs;

