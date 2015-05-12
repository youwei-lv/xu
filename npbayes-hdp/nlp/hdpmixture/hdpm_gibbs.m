function hdpm = hdpm_gibbs(hdpm,numiter)
% run numiter number of iterations of gibbs sampling in the DP mixture

KK = hdpm.KK; % number of globally active clusters
NN = hdpm.NN; % number of dps
aa_0 = hdpm.aa_0;
aa_1 = hdpm.aa_1;

qq = hdpm.qq; % 1*(KK+1) cell vector of mixture components
nn = hdpm.nn; % 1*KK vector of counts of tables for each component
dps = hdpm.dps;

for iter = 1:numiter
  % in each iteration, remove each data item from model, then add it back in
  % according to the conditional probabilities.

  for idp = 1:NN
      dp = dps{idp};
      dzz = dp.zz;
      dnn = dp.nn;
      dqq = dp.qq_ref;
      dtt = dp.tt;
      dtt_n = dp.tt_n;
      dKK = dp.KK;
      dxx = dp.xx;
      
      for ii = 1:length(dxx) % iterate over data items ii
          
          % remove data item xx{ii} from component qq{kk}
          kk = dzz(ii); % kk is the id of the components of the dp
          dnn(kk) = dnn(kk) - 1; % subtract from number of data items in component kk
          delitem(dqq{kk},dxx{ii}); % subtract data item sufficient statistics
          
          comptblno = dtt(ii); % table no in the component tables
          dtt_n{kk}(comptblno) = dtt_n{kk}(comptblno) - 1; % substract from the data number of the table
          % delete the table and decrease global number of tables if it has no customer
          if dtt_n{kk}(comptblno) == 0
              dtt_n{kk}(comptblno) = [];
              idx = ((dzz == kk) & (dtt > comptblno));
              dtt(idx) = dtt(idx) - 1; % relabel the table no after removing a table
              nn(dqq{kk}.id) = nn(dqq{kk}.id) - 1; % substract the table number in global
          end
          
          % delete active component if it has become empty
          if dnn(kk) == 0
              %fprintf(1,'del component %3d. K=%3d\n',find(nn==0),KK-sum(nn==0));
              dKK = dKK - 1;
              comp_ref = dqq{kk};
              dqq(kk) = [];
              dnn(kk) = [];
              dtt_n(kk) = [];
              idx = find(dzz>kk);
              dzz(idx) = dzz(idx) - 1; % relabel dish(component) no in the dp
              % if there is no table serving the dish globally, delete it
              % from the global menu
              dishNo = comp_ref.id;
              if nn(dishNo) == 0
                  nn(dishNo) = [];
                  for jj = dishNo+1:KK+1
                      qq{jj}.id = jj - 1;
                  end
                  qq(dishNo) = '';
                  KK = KK - 1;
              end
          end
          
          % compute conditional probabilities pp(kk) of data item ii
          % belonging to each component kk
          % compute probabilities in log domain, then exponential
          pp = log([dnn aa_1]);
          for kk = 1:dKK+1
              pp(kk) = pp(kk) + logpredictive(dqq{kk},dxx{ii});
          end
          pp = exp(pp - max(pp)); % -max(p) for numerical stability
          pp = pp / sum(pp);
          
          % choose component kk by sampling from conditional probabitilies
          uu = rand;
          kk = 1+sum(uu>cumsum(pp));
          
          % sits at a new table for which we are to draw a dish 
          if kk == dKK+1
              %fprintf(1,'add component %3d. K=%3d\n',kk,KK+1);
              pp = log([nn aa_0]);
              for kkk = 1:KK+1
                  pp(kkk) = pp(kkk) + logpredictive(qq{kkk},dxx{ii});
              end
              pp = exp(pp - max(pp)); % -max(p) for numerical stability
              pp = pp / sum(pp);
              
              % choose component kk by sampling from conditional probabitilies
              uu = rand;
              kkk = 1+sum(uu>cumsum(pp));
              
              % draw a new dish
              if kkk == KK+1
                  KK = KK+1;
                  nn(kkk) = 0;
                  qq{kkk+1} = qq{kkk}.copy;
                  qq{kkk+1}.id = qq{kkk+1}.id + 1;
              end
              
              nn(kkk) = nn(kkk) + 1;
              
              dqqidx = find(cellfun(@(q)q==qq{kkk},dqq(1:dKK)));
              % if the dish does not exist in current dp, then add a new
              % component to the dp
              if isempty(dqqidx)
                  dKK = dKK + 1;
                  dqq{dKK+1} = qq{KK+1};
                  dqqidx = dKK;
                  dqq{dqqidx} = qq{kkk};
                  dnn(dqqidx) = 0;
                  dtt_n{dqqidx} = [];
              end
              dzz(ii) = dqqidx;
              dtt(ii) = length(dtt_n{dqqidx}) + 1; % assgin a new table
              dnn(dqqidx) = dnn(dqqidx) + 1;
              dtt_n{dqqidx}(end+1) = 1;
          else
              % sit at an existing table in the current dp
              dnn(kk) = dnn(kk) + 1;
              dzz(ii) = kk;
              pp = dtt_n{kk}/sum(dtt_n{kk});
              comptblno = 1+sum(rand>cumsum(pp));
              dtt(ii) = comptblno;
              dtt_n{kk}(comptblno) = dtt_n{kk}(comptblno)+1;
          end
          
          % add data item xx{ii} back into model (component qq{kk})
          additem(dqq{dzz(ii)},dxx{ii}); % add sufficient stats of data item
      end
      
      dp.zz = dzz;
      dp.nn = dnn;
      dp.qq_ref = dqq;
      dp.tt = dtt;
      dp.tt_n = dtt_n;
      dp.KK = dKK;
      dps{idp} = dp;
  end
end

% save variables into dpm struct
hdpm.qq = qq;
hdpm.nn = nn;
hdpm.KK = KK;
hdpm.dps = dps;
