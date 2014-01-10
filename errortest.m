n = 200;
% n data points, in the interval [-1,1].
x = rand(n,1)*2-1;

% true parameters
ab0 = [2 .5];

% a function that predicts y, given x and the parameters
predfun = @(ab) ab(1)*exp(ab(2)*x);

% our data, to be used for estimation
y = randn(size(x))*.1 + predfun(ab0);

plot(x,y,'o')

% the estimation step, using fminsearch
sumofsquares = @(ab) sum((y - predfun(ab)).^2);
abstart = [1 1];
abfinal = fminsearch(sumofsquares,abstart)

% degrees of freedom in the problem
dof = n - 2;

% standard deviation of the residuals
sdr = sqrt(sum((y - predfun(abfinal)).^2)/dof)

% jacobian matrix
J = jacobianest(predfun,abfinal)
[H, err]=hessian(predfun,abfinal)

% I'll be lazy here, and use inv. Please, no flames,
% if you want a better approach, look in my tips and
% tricks doc.
Sigma = sdr^2*inv(J'*J);

% Parameter standard errors
se = sqrt(diag(Sigma))'

% which suggest rough confidence intervalues around
% the parameters might be...
abupper = abfinal + 2*se
ablower = abfinal - 2*se
