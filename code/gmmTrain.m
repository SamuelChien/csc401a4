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


    % Set default values if necessary.
    if nargin < 2
        max_iter = 50;
    end
    if nargin < 3
        epsilon = 0.001;
    end
    if nargin < 4
        M = 8;
    end


    %initialize data
    gmms = {};    
    speakerList = dir(dir_train);
    index_gmms = 1;
    gmmsOutputMatFileName = ['GMM_M' num2str(M) '-E' num2str(epsilon), '-I', num2str(max_iter), '.mat'];

    %loop through all the speakers data
    for index_i=1:length(speakerList)
        currentSpeakerName = speakerList(index_i).name;

        %Skip '.', '..', '.DS_store'
        if currentSpeakerName(1:1) == '.'
            continue;
        end

        %Get all mfcc data
        mfccList = dir([dir_train, filesep, currentSpeakerName, filesep, '*mfcc']);
        mfccMatrix = [];
        for index_j=1:length(mfccList)
            mfccMatrix = vertcat(mfccMatrix, load([dir_train, filesep, currentSpeakerName, filesep,  mfccList(index_j).name]));
        end


        %Initialize omega by gaussian mixture number
        D = size(mfccMatrix,2);
        omega = [];
        for m=1:M
            omega(:,:,m) = eye(D);
        end

        %Initialize Theta
        Theta = struct('name', currentSpeakerName, 'weights', ones(1,M)*(1/M), 'means', mfccMatrix(randperm(size(mfccMatrix,1))(1:M),:)', 'cov', omega);

        %initialize EM parameters
        iteration = 0;
        prev_L = -Inf;
        improvement = Inf;
        T = size(mfccMatrix,1);

        %Run EM Steps
        while iteration <= max_iter & improvement >= epsilon
            [weights, mus, omega, L] = emStep(Theta.weights, Theta.means, Theta.cov, mfccMatrix, M, T, D);

            Theta.weights = weights;
            Theta.means = mus;
            Theta.cov = omega;
            improvement = L - prev_L;
            prev_L = L;
            iteration = iteration+1;
        end

        gmms{index_gmms} = Theta;
        index_gmms = index_gmms + 1;

    end

    save( gmmsOutputMatFileName, 'gmms', '-mat' ); 
end



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %       Support functions           %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Credited to NATASHA for EM step function calculation
function [w, u, c, L]= emStep(w, u, c, x, M, T, D)

    b = zeros(T,M);

    for m=1:M
        um = u(:, m)'; %1xD
        cm = diag(c(:,:,m))'; %1xD
        numer = sum((((x-repmat(um, T, 1)).^2)./repmat(cm,T,1)), 2);
        numer = exp(-0.5 * numer); %Tx1

        denom = ((2*pi)^(D/2) * sqrt(prod(cm))); %scalar
        b(:,m) = numer/denom;
    end

    % b should now be calculated.

    p_x_theta = sum(repmat(w, T, 1).*b, 2); %Tx1
    L = sum(log2(p_x_theta));

    p_m_t = zeros(T,M); %TxM

    for m=1:M
        wm = w(1,m); %scalar
        p_m_t(:, m) = repmat(wm, T, 1).*b(:,m)./p_x_theta;
    end

    % Update parameters
    w = sum(p_m_t, 1)/T; %1xM
    u = (p_m_t' * x)'./repmat(sum(p_m_t, 1),D,1); %DxM
    c_d_m = (p_m_t' * (x.^2))'./repmat(sum(p_m_t, 1),D,1) - u.^2; %DxM

    for m=1:M
        c(:,:,m) = diag(c_d_m(:,m));
    end

end


