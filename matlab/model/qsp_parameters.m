function p = qsp_parameters
% QSP_PARAMETERS Canonical parameter set for the 20-state PLD-EA model.

p.Vp = 0.0097;
p.CLp = 0.0005;
p.kclr_lip = 0.029;
p.kRES = 0.013;
p.krel_RES = 0.010;

p.Ptum = 0.003;
p.Pheart = 0.0005;
p.kelim_tum = 0.007;
p.kelim_heart = 0.019;
p.kEPR = 0.005;

p.kKP = 0.06;
p.nKP = 0.43;
p.tau_floor = 1e-3;  % h, regularizes the KP derivative at cohort age zero

p.kprolif = 0.0231;
p.Kmax = 1e8;
p.kDOXkill = 0.075;
p.IC50 = 0.065;
p.EEA_pot = 1.0;
p.EC50_EA = 11.1;

p.Bss = [0.005 0.010 0.050 1.000 0.300];
p.bio = {'cTnI','cTnT','NT-proBNP','H-FABP','CK-MB'};
p.ktox = [0.52 1.25 3.33 3.78 2.22]/24;
p.krep = [20.8 16.6 33.3 30.2 5.5]/24;
p.EEA_j = [1.5 1.5 1.0 1.2 1.0];
p.EC50_j = [0.20 0.20 0.20 0.20 0.15];

p.kROSgen = 0.15;
p.kROSclear = 1.0;
p.kROSscav = 0.5;
p.KM_ROS = 10;
p.ROSss = 1.0;
p.kROSbasal = 1.0;

p.K10 = 0.54;
p.k12 = 1.90;
p.k21 = 0.47;
p.F = 0.01;
p.ka = 14.52;
p.VEA_p = 506.611;

p.EF_base = 75;
p.EF_nadir = 45;
p.FS_base = 40;
p.FS_nadir = 20;
p.gamma = 2;
p.AUC50_EF = 15;
p.AUC50_FS = 12;

p.DOX_dose = 937.5;
p.DOX_times = (0:4)*168;
p.EA_times = (0:34)*24;
p.TEND = 42*24;

% Sobol parameter metadata
p.sobol_names = {'Vp','CLp','kclr_lip','kRES','krel_RES','Ptum','Pheart','kEPR', ...
    'kelim_tum','kelim_heart','kKP','nKP','kprolif','Kmax','kDOXkill','IC50', ...
    'EC50_EA','EEA_pot','ka','K10','k12','k21','kROSgen','kROSclear', ...
    'kROSscav','KM_ROS','ktox_cTnI','krep_cTnI'};
p.sobol_nom = [p.Vp p.CLp p.kclr_lip p.kRES p.krel_RES p.Ptum p.Pheart p.kEPR ...
    p.kelim_tum p.kelim_heart p.kKP p.nKP p.kprolif p.Kmax p.kDOXkill p.IC50 ...
    p.EC50_EA p.EEA_pot p.ka p.K10 p.k12 p.k21 p.kROSgen p.kROSclear ...
    p.kROSscav p.KM_ROS p.ktox(1) p.krep(1)];
end

