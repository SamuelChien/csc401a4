% myRun
%
%  Purpose:  find the log likelihood of each phoneme sequence in the test data 
%            given each HMM phoneme model using the loglikHMM function
%
%  (c) Samuel Chien 2016


% %Initialize variables
modelOutputName = 'PhnToHMMDict.mat';
mfccDimensionSize = 14;
dataDir = '/u/cs401/speechdata/Testing';
outputTextFile = 'result.txt';
phnList = dir([dataDir, filesep, '*.phn']);
outputFile = fopen(outputTextFile, 'w');

total = 0;
correct = 0;

load(modelOutputName);

for index_i=1:length(phnList)

    currentUtterenceName = phnList(index_i).name(1:end-4);

    %open phn file
    [Starts, Ends, Phns] = textread([dataDir, filesep,  currentUtterenceName, '.phn'], '%d %d %s', 'delimiter','\n');

    %open mfcc file
    mfccData = load([dataDir, filesep,  currentUtterenceName, '.mfcc']);
    mfccData = mfccData';
    mfccData = mfccData(1:mfccDimensionSize, :);

    for index_k = 1:length(Phns)

        mfccStartLineIndex = Starts(index_k)/128 + 1;
        mfccEndLineIndex = min(Ends(index_k)/128 + 1, length(mfccData));
        phnKey = char(Phns(index_k));
        if strcmp(phnKey, 'h#')
            phnKey = 'sil';
        end


        max_log_instance = struct();
        max_log_instance.phn = '';
        max_log_instance.score = -Inf;

        phnDataKeys = fieldnames(PhnToHMMDict);

        for keyIndex = 1:length(phnDataKeys)    
            phnDataKey = phnDataKeys{keyIndex};
            score = loglikHMM(PhnToHMMDict.(phnDataKey), mfccData(:, mfccStartLineIndex:mfccEndLineIndex));

            if score > max_log_instance.score
                max_log_instance.phn = phnDataKey;
                max_log_instance.score = score;
            end

        end

        total = total + 1;
        if strcmp(max_log_instance.phn, phnKey)
            correct = correct + 1;
        end

        result = ['Accuracy:', int2str((correct*100)/total), ' Expected: ', phnKey, ' Computed: ', max_log_instance.phn];
        disp(result);
        fprintf(outputFile, '%s\n', result);

    end
    disp(['----- ', num2str(round(100*index_i/length(phnList))), '% COMPLETE -----']);  

end

result = ['accuracy is: ', int2str(correct), '/', int2str(total), ' = ', int2str((correct*100)/total)];
disp(result);
fprintf(outputFile, '%s\n', result);
fclose(outputFile);

