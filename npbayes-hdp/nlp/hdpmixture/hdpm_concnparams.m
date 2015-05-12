function [hdpm] = hdpm_concnparams(hdpm,gammaa1,gammab1,gammaa2,gammab2)

hdpm.aa_0 = RandDpConcnParam(hdpm.aa_0,sum(hdpm.nn),hdpm.KK,...
            gammaa1,gammab1,10);
        
numdata      = cellfun(@(dp) dp.numdata, hdpm.dps);
numclass     = cellfun(@(dp) dp.KK, hdpm.dps);
hdpm.aa_1 = RandDpConcnParam(hdpm.aa_1,numdata,numclass,gammaa2,gammab2);

end