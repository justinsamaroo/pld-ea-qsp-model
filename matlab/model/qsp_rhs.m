function dy = qsp_rhs(tt,y,p,eta_form,ec50_ea,ea_on)
% QSP_RHS Right-hand side for the canonical 20-state PLD-EA model.
%
% States 1:5 are liposomal DOX cohorts, 6 free plasma DOX, 7 RES DOX,
% 8 tumor DOX, 9 cardiac DOX, 10 viable tumor cells, 11:15 cardiac
% biomarkers, 16 cardiac ROS, 17 EA GI depot, 18 EA plasma, 19 EA
% peripheral tissue, and 20 cumulative cardiac DOX exposure.

dy = zeros(20,1);

Clip = max(y(1:5),0);
Cp = max(y(6),0);
CRES = max(y(7),0);
Ctum = max(y(8),0);
Cheart = max(y(9),0);
Cell = max(y(10),0);
B = max(y(11:15),0);
ROS = max(y(16),0);
AGI = max(y(17),0);
CEA_p = max(y(18),0);
CEA_t = max(y(19),0);

tau = tt-p.DOX_times(:);
active = tau>0;
tau_safe = max(tau,p.tau_floor);
krel = zeros(5,1);
krel(active) = p.kKP*p.nKP.*tau_safe(active).^(p.nKP-1);
release_total = sum(krel.*Clip);
total_lip = sum(Clip);

dy(1:5) = -krel.*Clip-p.kclr_lip.*Clip;
dy(6) = -(p.CLp/p.Vp)*Cp+release_total-p.kRES*Cp ...
    -p.Ptum*(Cp-Ctum)-p.Pheart*(Cp-Cheart);

% krel_RES is implemented as an untracked loss from the RES. No matching
% return flux enters plasma. This historical naming is documented as a limit.
dy(7) = p.kRES*Cp+p.kclr_lip*total_lip-p.krel_RES*CRES;

% The EPR input is not subtracted from the liposomal cohorts. This is the
% concentration-transfer approximation described in the manuscript.
dy(8) = p.Ptum*(Cp-Ctum)+p.kEPR*total_lip-p.kelim_tum*Ctum;
dy(9) = p.Pheart*(Cp-Cheart)-p.kelim_heart*Cheart;

if ea_on
    CEA_eff = eta_form*CEA_p;
else
    CEA_eff = 0;
end

kill_rate = p.kDOXkill*(1+p.EEA_pot*CEA_eff/(ec50_ea+CEA_eff));
dy(10) = p.kprolif*Cell*(1-Cell/p.Kmax) ...
    -kill_rate*Ctum*Cell/(p.IC50+Ctum);

kin = p.krep(:).*p.Bss(:);
krep_eff = p.krep(:).*(1+p.EEA_j(:).*CEA_eff./(p.EC50_j(:)+CEA_eff));
dy(11:15) = kin+p.ktox(:)*Cheart-krep_eff.*B;

dy(16) = p.kROSbasal+p.kROSgen*Cheart-p.kROSclear*ROS ...
    -p.kROSscav*CEA_eff*ROS/(p.KM_ROS+ROS);

dy(17) = -p.ka*AGI;
dy(18) = p.ka*p.F*AGI/p.VEA_p-p.K10*CEA_p-p.k12*CEA_p+p.k21*CEA_t;
dy(19) = p.k12*CEA_p-p.k21*CEA_t;
dy(20) = Cheart;
end

