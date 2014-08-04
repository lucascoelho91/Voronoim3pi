function bot = Voronoi_Approx(i,bot,Env)

% Find the approximated Voronoi configuration based

n = Env.n;
bot2(1) = bot(i);
po = [bot(i).x ; bot(i).y];
k = 2;
for j = 1:n
    if i ~= j
        pf = [bot(j).x ; bot(j).y];
        dist = norm(pf - po);
        if dist <= bot(i).Vrad
            bot2(k) = bot(j);
            k = k+1;
        end
    end
end

[V0, NI] = Voronoi_s(1,bot2,Env);

bot(i).Vi = V0;
bot(i).nb = NI;