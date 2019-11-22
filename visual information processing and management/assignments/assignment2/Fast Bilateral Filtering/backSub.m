function x = backSub (R, b, n)
x = zeros(n,1);
for k = n : -1 : 1
    x(k) =(b(k)-R(k,k:n)*x(k:n,1))/R(k,k);
end