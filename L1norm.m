function mae_score = L1norm(ideal,experiment)
%L1norm Calculates the mean absolute error of each trace.
%   First, the traces are normalized (constrained to 0-1). Then the
%   absolute difference between the experimental trace and ideal (averaged
%   of all) trace are averaged.
dif=0;
% scalar=max(ideal);
% ideal=ideal/scalar;
% scalar=max(experiment);
% experiment=experiment/scalar;
experiment=normalize(experiment);
ideal=normalize(ideal);

for ii = 1:length(ideal)
    dif=dif+abs(ideal(ii)-experiment(ii));
end
mae_score=dif/length(ideal);
end
