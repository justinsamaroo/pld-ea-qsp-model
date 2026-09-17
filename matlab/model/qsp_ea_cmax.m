function peak = qsp_ea_cmax(p)
% QSP_EA_CMAX Analytic EA PK with numerical peak location, 200 mg/kg daily.
% Uses the canonical nominal dosing schedule (35 daily doses, 250-g rat).
M = [-p.ka 0 0; p.ka*p.F/p.VEA_p -p.K10-p.k12 p.k21; 0 p.k12 -p.k21];
E = expm(24*M); y = zeros(3,1); peak = 0;
for day = 0:34
    y(1) = y(1)+50000;
    C = @(t) [0 1 0]*expm(M*t)*y;
    [~,negativePeak] = fminbnd(@(t) -C(t),0,24, ...
        optimset('TolX',1e-10,'Display','off'));
    peak = max([peak,-negativePeak,C(0),C(24)]);
    y = E*y;
end
fprintf('EA Cmax at 200 mg/kg: %.6f micrograms/mL\n',peak);
end

