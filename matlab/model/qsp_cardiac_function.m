function [EF,FS] = qsp_cardiac_function(p,AUC)
% QSP_CARDIAC_FUNCTION Algebraic EF and FS outputs from cardiac DOX AUC.

g = p.gamma;
EF = p.EF_base-(p.EF_base-p.EF_nadir).*AUC.^g ...
    ./(p.AUC50_EF^g+AUC.^g);
FS = p.FS_base-(p.FS_base-p.FS_nadir).*AUC.^g ...
    ./(p.AUC50_FS^g+AUC.^g);
end

