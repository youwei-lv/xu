function [hdp,sample,lik,predlik] = hdp2Multinomial_run(hh,alphaa,alphab,...
    numclass,trainss,testss,...
    trainnumburnin,trainnumsample,trainnumspace,...
    testnumburnin,testnumsample,trainconparam,testconparam,fid);

func = hdpMultinomial_func;

hdp = hdp_init(func,0,1,hh,alphaa,alphab); 
[hdp trainindex] = hdp_adddp(hdp,length(trainss),1,2);
[hdp testindex]  = hdp_adddp(hdp,length(testss),1,2);


hdp = hdp_setdata(hdp,trainindex,trainss);
hdp = hdp_setdata(hdp,testindex,testss); % added data is set to be held out by default

hdp = dp_activate(hdp,[1 trainindex],numclass); % activate the samplings for 
                                                % dps indexed by [1 trainindx]

% perform posterior sampling for activated dps, and store the state of each
% hdp during the iteration
[sample hdp lik] = hdp_posterior(hdp,trainnumburnin,trainnumsample,...
                   trainnumspace,trainconparam,1,0,fid);
% freeze the dps indexed by trainindex
hdp = dp_freeze(hdp,trainindex); 

% when performing hdp_predict, the trainindexed dps will be freezed, and
% testindexed dps will be activated and the likelihood will be computed
% testnumsample times after testnumburnin
predlik = hdp_predict(hdp,sample,trainindex,testindex,...
          testnumburnin,testnumsample,testconparam,0,fid);
