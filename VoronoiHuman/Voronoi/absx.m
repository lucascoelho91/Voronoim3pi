function y = absx(x)
    if (abs(x) > 1)
        y = x/abs(x);
    else
        y = x;
    end
end