function [paramsout,errout] = get_fit_params_using_pattern_search(spec_measured,massaxis,shape,molecules,parameters,lb,ub)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


opt=psoptimset('Display','iter');
opt=psoptimset(opt,'UseParallel', 'always', 'CompletePoll', 'on', 'Vectorized', 'off');
%With Cache set to 'on', patternsearch keeps a history of the mesh points it polls
%and does not poll points close to them again at subsequent iterations. Use this
%option if patternsearch runs slowly because it is taking a long time to compute
%the objective function.
opt=psoptimset(opt,'Cache','on');
opt=psoptimset(opt,'ScaleMesh','on');
opt=psoptimset(opt,'TolMesh',1e-6);

paramsout = patternsearch(@(x) msd(spec_measured,massaxis,shape,molecules,x),parameters,...
    [],[],[],[],lb,ub,[],opt);

errout=get_fitting_errors(spec_measured,massaxis,shape,molecules,paramsout,0.5);

end

