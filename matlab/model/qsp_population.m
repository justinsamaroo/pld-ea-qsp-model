function P = qsp_population(p,Nrats,seed)
% QSP_POPULATION Generate the documented virtual population.

rng(seed,'twister');
specs = { ...
    'CLp',p.CLp,0.20
    'Vp',p.Vp,0.20
    'kKP',p.kKP,0.25
    'nKP',p.nKP,0.15
    'Pheart',p.Pheart,0.40
    'kelim_heart',p.kelim_heart,0.30
    'kROSgen',p.kROSgen,0.40
    'kROSclear',p.kROSclear,0.25
    'ktox_cTnI',p.ktox(1),0.30
    'krep_cTnI',p.krep(1),0.30};

np = size(specs,1);
P.names = specs(:,1)';
P.PeakCp = zeros(1,Nrats);
P.PeakCheart = zeros(1,Nrats);
P.PeakROS = zeros(1,Nrats);
P.FinalEF = zeros(1,Nrats);
P.theta = zeros(Nrats,np);
P.seed = seed;
P.Nrats = Nrats;
P.matlab_version = version;

for rat = 1:Nrats
    pp = p;
    for parameter = 1:np
        nominal = specs{parameter,2};
        cv = specs{parameter,3};
        sigma = sqrt(log(1+cv^2));
        mu = log(nominal)-sigma^2/2;
        value = exp(mu+sigma*randn);
        P.theta(rat,parameter) = value;
        switch specs{parameter,1}
            case 'ktox_cTnI'
                pp.ktox(1) = value;
            case 'krep_cTnI'
                pp.krep(1) = value;
            otherwise
                pp.(specs{parameter,1}) = value;
        end
    end
    pp.kROSbasal = pp.kROSclear*pp.ROSss;
    [~,states] = qsp_run(pp,struct('ea_dose',0,'npts',1200));
    P.PeakCp(rat) = max(states(:,6));
    P.PeakCheart(rat) = max(states(:,9));
    P.PeakROS(rat) = max(states(:,16));
    P.FinalEF(rat) = qsp_cardiac_function(pp,states(end,20));
end
end
