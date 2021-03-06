function [output] = ml_applyGP(features, model)
%ML_APPLYGP prediction using Gaussian Process classification model
% the GPML toolbox
% Dependencies : GPML toolbox [1]
% References :
% [1] Rasmussen, C., & Hannes, N. (2010). Gaussian processes for machine
% learning (GPML) toolbox. Journal of Machine Learning Research,
% 11, 3011�3015. https://doi.org/10.1142/S0129065704001899
% created 01-21-2019
% last modified -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>


nSamples = size(features.x,1);
nClasses = numel(unique(features.y));
output.accuracy = 0;
output.y = zeros(1,nSamples);
output.score = zeros(1,nSamples);
output.trueClasses = features.y;

if(nClasses == 2)
    [ymu,ys2, fmu ,fs2,lp] = gp(model.hyp, model.infFunc, model.meanFunc, ...
        model.covFunc, model.likFunc, model.x, model.y,...
        features.x, features.y);
    probs = 1./(1 + exp(-fmu));
    probs = [probs, 1-probs];
    [~,predicted_label] = max(probs, [], 2);
    predicted_label(predicted_label==2)=-1;
else
    probs = zeros(nSamples, nClasses);
    for m=1:nClasses
        y1 = model.y;
        y1(model.y==m) = 1;
        y1(model.y~=m) = -1;
        yy = ones(nSamples, 1);
        yy(features.y~=m) = -1;
        [ymu,ys2, fmu ,fs2,lp] = gp(model.models{m}.hyp, model.infFunc, ...
            model.meanFunc, model.covFunc, ...
            model.likFunc, model.x, y1,...
            features.x, yy);
        probs(:,m) = 1./(1 + exp(-fmu));
    end
    [~,predicted_label] = max(probs, [], 2);
end
output.y = predicted_label;
output.score = probs;
nMisClassified = sum(output.trueClasses ~= output.y);
output.accuracy = ((nSamples - nMisClassified)/nSamples) * 100;
output = ml_get_performance(output);
output.lp = lp;
output.subject = '';
output.alg = model.alg;
end

