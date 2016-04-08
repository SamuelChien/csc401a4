function gmms = gmmTrain( dir_train, max_iter, epsilon, M )
% gmmTain
%
%  inputs:  dir_train  : a string pointing to the high-level
%                        directory containing each speaker directory
%           max_iter   : maximum number of training iterations (integer)
%           epsilon    : minimum improvement for iteration (float)
%           M          : number of Gaussians/mixture (integer)
%
%  output:  gmms       : a 1xN cell array. The i^th element is a structure
%                        with this structure:
%                            gmm.name    : string - the name of the speaker
%                            gmm.weights : 1xM vector of GMM weights
%                            gmm.means   : DxM matrix of means (each column 
%                                          is a vector
%                            gmm.cov     : DxDxM matrix of covariances. 
%                                          (:,:,i) is for i^th mixture

    directory = dir(dir_train);
    gmms = {};
    
    % Get data (gmms) from dir_train
    for folder=3:length(directory)
        %initalize theta = [w_m, mu_m, sigma_m] for m = 1...M
        file_path = [dir_train, '/', directory(folder).name, '/'];
        sub_directory = dir([file_path, '*', '.mfcc']);
        x = [];
        for file=1:length(sub_directory)
            x = vertcat(x, load([file_path, sub_directory(file).name]));
        end
        
        theta = struct();
        theta.mu = rand(14, M); %dxM
        theta.w = rand(1, M); %1xM
        theta.sigma = rand(14, M); %actually diagonal DxDxM
        
        i = 0;
        prev_L = -inf;
        improvement = inf;
        %disp(improvement >= epsilon);
        while i < max_iter && improvement >= epsilon
            L = computeLikelihood(x, theta, M);
            theta = updateParameters(theta, x, L, M);
            improvement = L - prev_L;
            prev_L = L;
            i = i+1;
            %disp(improvement);
        end
        
        gmms{folder-2}.name = directory(folder).name;
        gmms{folder-2}.weights = theta.w;
        gmms{folder-2}.means = theta.mu;
        gmms{folder-2}.cov = theta.sigma;
    end
    
end
function p = computeLikelihood(x, theta, M)
    T = size(x, 1);
    %calculate bm(x_t)
    b = zeros(T, M);
    for m=1:M
        mu_m = theta.mu(:,m)';
        cov_m = theta.sigma(:,m);
        
        x_max = max(x);
        
        numerator = sum(((x - repmat(mu_m, T, 1)).^2)/diag(cov_m), 2);
        numerator = exp(0.5*numerator);
        denom = ((2 * pi)^(14/2)) * sqrt(prod(cov_m));
        b(:, m) = numerator/denom;
    end
    p = zeros(T, M);
    for m=1:M
        %disp(size(repmat(theta.w(:,m), T, 1), 1))
        disp(size(b(:,m), 1))
        numerator = repmat(theta.w(:, m), T, 1)' * b(:, m);
        denom = sum(repmat(theta.w, T, 1)' * b);
        p(:, m) = numerator/denom;
        
    end
end
function theta =  updateParameters(theta, x, L, M)
    T = size(x, 1);
    for m=1:M
        %theta = [w, mu, sigma]
        L_m = L(:, m);
        theta.w(:, m) = sum(L_m)/T;
        theta.mu(:, m) = sum(repmat(L_m, T, 1) * x) / sum(L_m);
        theta.sigma(:, m) = (sum(repmat(L_m, T, 1) * x.^2) / sum(L_m)) - theta.mu(:, m).^2;
    end
end
    