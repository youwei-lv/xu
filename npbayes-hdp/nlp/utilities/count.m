function [cv]=count(v,kk)
cv = zeros(1,kk);
for i=1:length(v)
    cv(v(i)) = cv(v(i)) + 1;
end
end