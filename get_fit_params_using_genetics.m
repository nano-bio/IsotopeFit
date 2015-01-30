function [paramsout,errout] = get_fit_params_using_genetics(spec_measured,massaxis,shape,molecules,parameters,lb,ub)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

opt = gaoptimset('PopInitRange',[parameters/2;parameters*2]);
opt = gaoptimset(opt,'EliteCount',2*length(parameters));
opt = gaoptimset(opt,'PopulationSize',50*length(parameters));
opt = gaoptimset(opt,'Display','iter');
%opt = gaoptimset(opt,'PlotFcns',{@gaplotbestf,@gaplotstopping});
opt = gaoptimset(opt,'TolFun',0.1);

paramsout = ga(@(x) msd(spec_measured,massaxis,shape,molecules,x),length(parameters),...
    [],[],[],[],lb,ub,[],opt);

errout=get_fitting_errors(spec_measured,massaxis,shape,molecules,paramsout,0.5);

end

