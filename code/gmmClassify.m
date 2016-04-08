% gmmClassify
%
%  Purpose:  Train and output classification
%
%  (c) Samuel Chien 2016


dir_test = '/u/cs401/speechdata/Testing';
dir_train = '/u/cs401/speechdata/Training';
M = 8;
fn_suffix = '.lik';

gmms = gmmTrain(dir_train);

testDir = dir([dir_test, filesep, '*', 'mfcc']);

for index_i=1:length(testDir)

    currentUtterenceName = testDir(index_i).name(1:end-5);

    %Read mfcc data
    mfccData = load([dir_test, filesep, currentUtterenceName, '.mfcc']);
    T = size(mfccData, 1);
    D = size(mfccData,2);

    %log likelihood initialization
    logScore = zeros(length(testDir),1);

    for index_j=1:length(gmms)
        means = gmms{index_j}.means;
        weights = gmms{index_j}.weights;
        covs = gmms{index_j}.cov;
        offset = zeros(T,M);

        %compute loglikelihood
        for m=1:M
            um = means(:, m)'; %1xD
            cm = diag(covs(:,:,m))'; %1xD
            numer = sum((((x-repmat(um, T, 1)).^2)./repmat(cm,T,1)), 2);
            numer = exp(-0.5 * numer); %Tx1

            denom = ((2*pi)^(D/2) * sqrt(prod(cm))); %scalar
            offset(:,m) = numer/denom;
        end

        p_x_theta = sum(repmat(weights, T, 1).*offset, 2); %Tx1
        L = sum(log2(p_x_theta));
        logScore(s,1) = L;
    end

    %sort loglikelihood
    logLikelihoodIndex = horzcat((1:length(logScore))', logScore);
    logLikelihoodScore = sortrows(logLikelihoodIndex, 2);

    %ouput top five log likelihood guess
    top1 = gmms{logLikelihoodScore(end,1)}.name;
    top2 = gmms{logLikelihoodScore(end-1,1)}.name;
    top3 = gmms{logLikelihoodScore(end-2,1)}.name;
    top4 = gmms{logLikelihoodScore(end-3,1)}.name;
    top5 = gmms{logLikelihoodScore(end-4,1)}.name;

    outputFileName = [currentUtterenceName, fn_suffix];
    outputFile = fopen(outputFileName, 'wt');
    fprintf(outputFile, '%s\n%s\n%s\n%s\n%s\n', top1, top2, top3, top4, top5);
    fclose(outputFile);

end