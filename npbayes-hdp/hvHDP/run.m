fname = 'data/abstracts.txt';
vobfname = 'data/abstracts_pairs.txt';

[docs,vobsize] = readId2NumFile(fname);
[vob] = readVobFile(vobfname);

alphaa = [1,1];
alphab = [0.1,1];

eta = 0.1;
hh = 0.1*ones(vobsize,1);
numclass = 10;

[hdp,docdpidx] = hdp2Multinomial_init(hh,alphaa,alphab,numclass,docs,{});

iterSize = 50;
numiter = 100;
doconparam = 15;

sample = cell(1,iterSize);

for iter=1:iterSize
  hdp = hdp_iterate(hdp,numiter,doconparam,0,0);
  sample{iter} = hdp_getstate(hdp);
end


