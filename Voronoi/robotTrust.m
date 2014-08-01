function t = robotTrust( boti )
    if(boti.mal == 1)
        t = 1;
    elseif(boti.mal == 2)
        t = 1;
    elseif(boti.mal == 3)
        t = 2;
    elseif(boti.mal == 4)
        t = 1 - boti.eff;     
    else
        t = norm(boti.K);
    end
end

