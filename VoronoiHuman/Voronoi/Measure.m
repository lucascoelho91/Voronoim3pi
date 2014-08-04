function phip = Measure(Env,p)
%Mac SChwager, MIT, 2006
% Returns the value of phi at point p

varphi = Env.varphi;
alpha = Env.strength;
beta = Env.stdev;
gamma = Env.peaks;
offset = Env.offset;



if varphi == 1
    m = length(alpha);
    z = sqrt((p(1) - gamma(:,1)).^2 + (p(2) - gamma(:,2)).^2).*beta.^-1;
    g = beta.^-1/sqrt(2*pi).*exp(-.5*z.^2);
    phip = alpha'*g + sum(offset);

else  
    phip = 1;
end


end