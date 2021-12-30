clear all; close all; clc

%% Dataset
interval = 1000;
mu = [1 10 100];
sigma = [1 1 1; 3 3 3; 5 5 5];
R = chol(sigma);
z = repmat(mu,interval,1) + randn(interval,3)*R;
arr = [z(:,1); z(:,2); z(:,3)]; % dataset5


%% Iterative descriptive statistics
M1 = 0;  M2 = 0;  M3 = 0;  M4 = 0;  n = 0;   
xmax = -10000; xmin = 10000;
iter = 1; 

for k = 1:length(arr)
    x = arr(k); % Raw data
    
    % "" (start) Iterative descriptive statistics ""
    n1 = n;
    n = n+1;
    delta = x - M1;
    delta_n = delta / n;
    delta_n2 = delta_n * delta_n;
    gamma = delta * delta_n * n1;
    M1 = M1 + delta_n;
    M4 = M4 + gamma * delta_n2 * (n*n - 3*n + 3) + 6 * delta_n2 * M2 - 4 * delta_n * M3;
    M3 = M3 + gamma * delta_n * (n - 2) - 3 * delta_n * M2;
    M2 = M2 + gamma;
    % "" (end) Iterative descriptive statistics ""

    % Dispersion tendency
    if x >= xmax, xmax = x; end
    if x <= xmin, xmin = x; end
    xrange = xmax-xmin;
    
    % "" (start) Non-overlapped sliding-window closed ""
    if k >= interval*iter
        % Iterative results
        algorithm.mean(iter) = M1;
        algorithm.var(iter) = M2/(n-1);
        algorithm.std(iter) = sqrt(M2/(n-1));
        algorithm.skew(iter) = sqrt(n/(M2^3))*M3;
        algorithm.kurt(iter) = n*M4 / (M2*M2);
        algorithm.range(iter) = xrange;
        algorithm.max(iter) = xmax;
        algorithm.min(iter) = xmin;
        
        M1 = 0;  M2 = 0;  M3 = 0;  M4 = 0;  n = 0;   % Initialization
        xmax = -10000; xmin = 10000;
        
        iter = iter + 1;
    end
    % "" (end) Window closed ""
    
end

%% Conventional results (Comparison)
x1 = [];
iter = 1;

for k = 1:length(arr);
    x = arr(k); % Raw data
    x1 = [x1; x];
    
    % "" (start) Window closed ""
    if k >= interval*iter        
        
        answer.mean(iter) = mean(x1);
        answer.var(iter) = var(x1);
        answer.std(iter) = std(x1);
        answer.skew(iter) = skewness(x1);
        answer.kurt(iter) = kurtosis(x1);
        answer.range(iter) = range(x1);
        answer.max(iter) = max(x1);
        answer.min(iter) = min(x1);
        
        x1 = [];
        
        iter = iter + 1; 
    end
    % "" (end) Window closed ""
end

fprintf("Recursive algorithm: \n\n")
disp(algorithm)
fprintf("\n MATLAB-embedded function : \n\n")
disp(answer)
  