function y = wdiff(boti, botj, sumgama)

    y = boti.kpw * (boti.wt - botj.wt) * exp(-(sumgama/(2*boti.kpwg))^2);