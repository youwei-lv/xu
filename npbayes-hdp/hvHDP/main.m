%function [hvHDPs]= main
fname = 'data/abstracts.txt';
vobfname = 'data/abstracts_pairs.txt';

[docs,vobsize] = readId2NumFile(fname);

%datass = docs(1:100);
datass = docs;

initnumclass = 10;
eta = 0.1;
gammaa1 = 1;
gammab1 = 0.1;
gammaa2 = 1;
gammab2 = 0.1;
aa_0 = 1;
aa_1 = 1;

hh0.aa = eta*vobsize;
hh0.dd = vobsize;

numiter = 1000;

[hvHDPs] = hvHDP_main(datass, initnumclass, hh0, aa_0, aa_1, gammaa1, gammab1, gammaa2, gammab2, numiter);


[vob] = readVobFile(vobfname);

[tt,ttww] = showHDPs(hvHDPs,vob);



%end