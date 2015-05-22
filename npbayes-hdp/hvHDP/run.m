fname = 'data/abstracts.txt';
vobfname = 'data/abstracts_pairs.txt';

[docs,vobsize] = readId2NumFile(fname);
[vob] = readVobFile(vobfname);

alphaa = [1,1];
alphab = [1,1];

eta = 0.1;
hh = 0.1*ones(vobsize,1);
numclass = 10;
iterSize = 30;
numiter = 100;
doconparam = 15;

[hdp,docdpidx] = hdp2Multinomial_init(hh,alphaa,alphab,numclass,docs,{});

for iter=1:iterSize
  hdp = hdp_iterate(hdp,numiter,doconparam,0,0);
end

hdp_sample = hdp_getstate(hdp);

hdpTree = '';
MAX_HEIGHT = 5;

hdpTree{1} = hdp_sample;

height = 1;
while height < MAX_HEIGHT
    % transform document space
    KK = hdp_sample.numclass;
    if KK == 1
        break;
    end
    
    trainss = cell(1,KK);
    for iK = 1:KK
        trainss{iK} = expandCountingVector(hdp_sample.classqq(:,iK));
    end
    
    hh = hh + 0.5;
    [hdp,trainssidx] = hdp2Multinomial_init(hh,alphaa,alphab,numclass,trainss,{});
    
    for iter=1:iterSize
        hdp = hdp_iterate(hdp,numiter,0,0,0); % fix the concentration parameters
    end
    
    hdp_sample = hdp_getstate(hdp);
    
    height = height + 1;
    hdpTree{height} = hdp_sample;
end
