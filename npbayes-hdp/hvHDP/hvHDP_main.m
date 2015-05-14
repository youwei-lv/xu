function [hvHDPs] = hvHDP_main(datass, initnumclass, hh0, aa_0, aa_1, gammaa1, gammab1, gammaa2, gammab2, numiter)

datass_zz = cellfun(@(data)randi(initnumclass,1,length(data)),datass,'UniformOutput',false);
% initialize DP mixture
hdpm = hdpm_init(initnumclass,aa_0,Multinomial(hh0),datass,datass_zz,aa_1);

KK_hist = [];
tic
for iter = 1:numiter
    fprintf(1,'iter %d:  number of class = %d  using %.3f mins. \n', iter, hdpm.KK, toc/60);
    tic;
    % gibbs iteration
    hdpm = hdpm_gibbs(hdpm,1);
    % update dp concentration parameters
    hdpm = hdpm_concnparams(hdpm,gammaa1,gammab1,gammaa2,gammab2);
    
    if length(KK_hist) < hdpm.KK
        KK_hist(hdpm.KK) = 0;
    end
    KK_hist(hdpm.KK) = KK_hist(hdpm.KK) + 1;
end

[~,KK] = max(KK_hist);

KK = 50;
aa = 0.1*KK;
fm = fm_docs_init(KK,aa,Multinomial(hh0),datass,datass_zz);

dirName = ['data/AbstractAnalysisResult_', datestr(now, 30)];
if ~exist(dirName,'dir')
    mkdir(dirName);
end

tic;
for iter = 1:numiter
   fprintf(1,'iter %d using %.3f mins.\n', iter, toc/60);
   tic;
   % gibbs iteration 
   [fm,sampleRecord] = fm_gibbs_docs(fm,1);
   save([dirName,'/',num2str(iter),'.mat'],'fm','sampleRecord');
end


end