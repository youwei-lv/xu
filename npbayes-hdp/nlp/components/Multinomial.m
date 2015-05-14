classdef Multinomial < handle
    % qq = Multinomial(hh)
    % Creates a multinomial component containing no data items,
    % and symmetric Dirichlet prior given by hh.
    %
    % MODEL:
    % hh.dd         = (1x1) dimensionality
    % hh.aa         = (1x1) parameter for symmetric Dirichlet
    % qq.pi         = (dx1) multinomial probabilities
    % xx            = (dx1) sparse counts
    % mm            = (1x1) total counts in xx
    % mi            = (dx1) sparse counts of each category
    %
    % qq.pi         ~ Dirichlet(hh.aa/hh.dd,...,hh.aa/hh.dd)
    % xx | mm,hh,qq ~ Multinomial(mm,qq.pi)
    properties
        id
        dd
        mm
        nn
        aa
        mi
        Z0
    end
    
    methods
        function qq = Multinomial(hh)
            if nargin < 1
                return;
            end
            qq.dd = hh.dd;
            qq.aa = hh.aa/hh.dd;
            qq.mi = zeros(hh.dd,1);
            qq.mm = 0;
            qq.nn = 0;
            qq.Z0 = 0;
        end
        
        function qq = additem(qq,xx)
            % qq = additem(qq,xx)
            % adds data item xx into component qq.
            % xx can either be a sparse dx1 vector of counts,
            % or a scalar indicating value of a single draw.
            
%             if issparse(xx)
%                 [xii, xjj, xmi] = find(xx);
%                 xmm    = sum(xmi);
%                 qq.nn = qq.nn + 1;
%                 qq.mi = qq.mi + xx;
%                 qq.mm = qq.mm + xmm;
%                 qq.Z0 = qq.Z0 + gammaln(xmm+1) - sum(gammaln(xmi+1));
%             elseif isscalar(xx)
                qq.nn     = qq.nn + 1;
                qq.mi(xx) = qq.mi(xx) + 1;
                qq.mm     = qq.mm + 1;
%             else
%                 error('data item xx type unknown.');
%             end
        end
        
        function qq = delitem(qq,xx)
            % qq = delitem(qq,xx)
            % deletes data item xx into component qq.
            % xx can either be a sparse dx1 vector of counts,
            % or a scalar indicating value of a single draw.
            
%             if issparse(xx)
%                 [xii, xjj, xmi] = find(xx);
%                 xmm    = sum(xmi);
%                 qq.nn = qq.nn - 1;
%                 qq.mi = qq.mi - xx;
%                 qq.mm = qq.mm - xmm;
%                 qq.Z0 = qq.Z0 - gammaln(xmm+1) + sum(gammaln(xmi+1));
%             elseif isscalar(xx)
                qq.nn     = qq.nn - 1;
                qq.mi(xx) = qq.mi(xx) - 1;
                qq.mm     = qq.mm - 1;
%             else
%                 error('data item xx type unknown.');
%             end
        end
        
        function ll = logpredictive(qq,xx)
            % ll = logpredictive(qq,xx)
            % log predictive probability of xx given other data items in the component
            % log p(xx|x_1,...,x_n)
%             
%             if issparse(xx)
%                 [xii, xjj, xmi] = find(xx);
%                 xmm = sum(xmi);
%                 ll = gammaln(xmm+1) - sum(gammaln(xmi+1)) ...
%                     + gammaln(qq.aa*qq.dd+qq.mm) - gammaln(qq.aa*qq.dd+qq.mm+xmm) ...
%                     + full(sum(gammaln(qq.aa+qq.mi+xx) - gammaln(qq.aa+qq.mi)));
%             elseif isscalar(xx)
                ll = log((qq.aa+qq.mi(xx))/(qq.aa*qq.dd+qq.mm));
%             else
%                 error('data item xx type unknown.');
%             end
        end
        
        function pi = mean(qq)
            % pi = mean(qq)
            % returns the mean of pi given the data items in the component.
            
            pi = (qq.aa + qq.mi) / (qq.aa*qq.dd + qq.mm);
        end
        
        function ll = logmarginal(qq)
            % ll = logmarginal(qq)
            % log marginal probability of data items in the component
            % log p(x_1,...,x_n)
            
            [ii, jj, xmi] = find(qq.mi);
            ll = qq.Z0 + gammaln(qq.aa*qq.dd) - gammaln(qq.aa*qq.dd+qq.mm) ...
                - length(xmi)*gammaln(qq.aa) + full(sum(gammaln(qq.aa+xmi)));
        end
        
        function disp(qq)
            % disp Multinomial
            
            [xii, xjj, xmi] = find(qq.mi);
            disp(['Multinomial: d=' num2str(qq.dd) ...
                ' a=' num2str(qq.aa*qq.dd) ...
                ' n=' num2str(qq.nn) ...
                ' m=' num2str(qq.mm)]);
            if qq.mm>0
                disp(sprintf('%d:%d ',cat(1,xii',xmi')));
            end
        end
        
        function display(qq)
            % display Multinomial
            
            if isequal(get(0,'FormatSpacing'),'compact')
                disp([inputname(1) ' = ']);
                disp(qq);
            else
                disp(' ');
                disp([inputname(1) ' = ']);
                disp(' ');
                disp(qq);
            end
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
end