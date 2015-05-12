classdef Gaussian < handle  
    properties
        id
        dd
        nn
        rr
        vv
        CC
        XX
        Z0
    end
    
    methods
        % Creates a gaussian component containing no data items,
        % and gaussian-wishart prior given by hh.
        %
        % MODEL:
        % hh.dd       = (1x1) dimensionality
        % hh.ss       = (1x1) relative variance of mm versus data (cluster separability)
        % hh.VV       = (dxd) mean covariance matrix of clusters.
        % hh.vv       = (1x1) degrees of freedom of inverse Wishart covariance prior.
        % hh.uu       = (dx1) prior mean vector
        % RR          = (dxd) precision matrix
        % mm          = (dx1) mean vector
        % xx          = (dx1) data vector
        %
        % RR          ~ Wishart(hh.dd, hh.vv, hh.SS)
        % mm          ~ Normal(hh.dd, hh.uu, hh.rr*RR)
        %
        % xx | hh     ~ Normal(hh.dd, mm, RR) iid
        %
        function [obj] = Gaussian(hh)
            if nargin == 0
                return;
            end
            hh.rr = 1/hh.ss;
            hh.SS = hh.VV*(hh.vv); %-hh.dd-1);
            
            obj.dd = hh.dd;
            obj.nn = 0;                  % number of items.
            obj.rr = hh.rr;
            obj.vv = hh.vv;
            obj.CC = chol(hh.SS + hh.rr*hh.uu*hh.uu');
            obj.XX = hh.rr*hh.uu;
            obj.Z0 = Gaussian.ZZ(hh.dd,obj.nn,obj.rr,obj.vv,obj.CC,obj.XX);
        end
        
        % adds data item xx into the component
        function [obj] = additem(obj,xx)
            obj.nn = obj.nn + 1;
            obj.rr = obj.rr + 1;
            obj.vv = obj.vv + 1;
            obj.CC = cholupdate(obj.CC,xx);
            obj.XX = obj.XX + xx;
        end
        
        % deletes data item xx from  the component
        function [obj] = delitem(obj,xx)
            obj.nn = obj.nn - 1;
            obj.rr = obj.rr - 1;
            obj.vv = obj.vv - 1;
            obj.CC = cholupdate(obj.CC,xx,'-');
            obj.XX = obj.XX - xx;
        end
        
        % log predictive probability of xx given other data items in the component
        % log p(xx|x_1,...,x_n)
        function [ll] = logpredictive(obj,xx)
            ll =   Gaussian.ZZ(obj.dd,obj.nn+1,obj.rr+1,obj.vv+1,cholupdate(obj.CC,xx),obj.XX+xx) ...
                 - Gaussian.ZZ(obj.dd,obj.nn  ,obj.rr  ,obj.vv  ,           obj.CC    ,obj.XX   );
        end
        
        % Returns MAP estimate for mean and covariance of data items in the component.
        function [mu,sigma] = rand(obj)
            vCC = cholupdate(obj.CC,obj.XX/sqrt(obj.rr),'-')\eye(obj.dd);

            sigma = iwishrnd(vCC,obj.vv,vCC);
            mu = mvnrnd(obj.XX'/obj.rr, sigma/obj.rr)';
        end
        
        % Returns MAP estimate for mean and covariance of data items in the component.
        function [mu,sigma] = map(obj)
            mu = obj.XX/obj.rr;
            vCC = cholupdate(obj.CC,obj.XX/sqrt(obj.rr),'-');
            sigma = vCC'*vCC/(obj.vv-obj.dd-1);
        end
        
        % disp GaussianWishart
        function [] = disp(obj)
            [mu,sigma] = obj.map;
            disp(['GaussianWishart: d=' num2str(obj.dd) ...
                ' n=' num2str(obj.nn) ...
                ' r=' num2str(obj.rr) ...
                ' v=' num2str(obj.vv)]);
            disp(' mu=');
            disp(mu);
            disp(' sigma=');
            disp(sigma);
        end
        
        function new = copy(this)
            % Instantiate new object of the same class.
            new = feval(class(this));
            
            % Copy all non-hidden properties.
            p = properties(this);
            for i = 1:length(p)
                new.(p{i}) = this.(p{i});
            end
        end
    end
    
    methods(Static)
        function zz = ZZ(dd,nn,rr,vv,CC,XX)
            zz = - nn*dd/2*log(pi) ...
                - dd/2*log(rr) ...
                - vv*sum(log(diag(cholupdate(CC,XX/sqrt(rr),'-')))) ...
                + sum(gammaln((vv-(0:dd-1))/2));
        end
    end
    
end

