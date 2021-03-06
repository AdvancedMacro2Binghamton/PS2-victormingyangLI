close all
%%%% Set up parameters
alpha = 0.35;
beta = 0.99;
delta = 0.025;
sigma = 2;

%%%% Set up technology shock and transition matrix
A_h = 1.1;
A_l = 0.678;
A = A_h;
pi_hh = 0.977;
pi_ll = 0.926;
pi = [pi_hh 1-pi_hh; 1-pi_ll pi_ll];

%%%% Set up discretized state space
k_min = 0;
k_max = 45;
num_k = 1000; % number of points in the grid for k

k = linspace(k_min, k_max, num_k);

k_mat = repmat(k', [1 num_k]); % this will be useful in a bit
% Why do this?

%%%% Set up consumption and return function
% 1st dim(rows): k today, 2nd dim (cols): k' chosen for tomorrow
cons = A * (k_mat .^ alpha) + (1 - delta) * k_mat - k_mat'; % Why is k_mat' K_t+1?

ret = cons .^ (1 - sigma) / (1 - sigma); % return function
% negative consumption is not possible -> make it irrelevant by assigning
% it very large negative utility
ret(cons < 0) = -Inf;

%%%% Iteration
dis = 1; tol = 1e-06; % tolerance for stopping 
v_guess = zeros(1, num_k);
% A_vec = zeros(1, num_k); % create a matrix A_mat to keep track of A's
% i = 1;
while dis > tol
    % assign the value of current A into A_mat
    % A_vec(1, i) = A;
    % generate a random number as the probability of changing state
    X = rand;
    % compute the utility value for all possible combinations of k and k' with A_h or A_l:
    if A == A_h
        value_mat = ret + beta * (pi(1,1) * repmat(A_h * v_guess, [num_k 1]) + pi(1,2) * repmat(A_l * v_guess, [num_k 1]));
        if X > pi(1, 1)
            A = A_l;
        end
    else
        value_mat = ret + beta * (pi(2,1) * repmat(A_h * v_guess, [num_k 1]) + pi(2,2) * repmat(A_l * v_guess, [num_k 1]));
        if X < pi(2, 1)
            A = A_h;
        end
    end
    % find the optimal k' for every k:
    [vfn, pol_indx] = max(value_mat, [], 2);
    vfn = vfn';
    
    % what is the distance between current guess and value function
    dis = max(abs(vfn - v_guess));
    
    % if distance is larger than tolerance, update current guess and
    % continue, otherwise exit the loop
    v_guess = vfn;
    
    % increase i to move to the next position of A_mat
    % i = i + 1;
end

g = k(pol_indx); % policy function

plot(k,vfn)
figure
plot(k,g)
% How to plot policy function over K for each state of A? plot(k,g)?
% figure
% plot(A_vec,g)
% How to plot savings over K for each state of A?
% figure
% plot(A_vec,k)


