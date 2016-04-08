
% myTrain
%
%  Purpose: Train HMM using Bayes Net Toolbox. 
%		Task 1: Collect data
%		Task 2: Initialize HMM by Phonemes
%		Task 3: Train HMM by input data
%		Task 4: Save the model after training
%
%  (c) Samuel Chien 2016

%Initialize variables
modelOutputName = 'PhnToHMMDict.mat';
mfccDimensionSize = 14;
%dataDir = 'devSpeechData';
dataDir = '/u/cs401/speechdata/Training';



%Task 1: Collect data
speakerList = dir(dataDir);
phnData = struct();

%loop through all the speakers data
for index_i=1:length(speakerList)
    currentSpeakerName = speakerList(index_i).name;

    %Skip '.', '..', '.DS_store'
    if currentSpeakerName(1:1) == '.'
        continue;
    end

    speakerDirPath = [dataDir, filesep, currentSpeakerName, filesep];
    phnList = dir([speakerDirPath, '*phn']);

    for index_j=1:length(phnList)

        currentUtterenceName = phnList(index_j).name(1:end-4);
       
        %open phn file
        [Starts, Ends, Phns] = textread([speakerDirPath,  currentUtterenceName, '.phn'], '%d %d %s', 'delimiter','\n');

        %open mfcc file
        mfccData = load([speakerDirPath,  currentUtterenceName, '.mfcc']);
        mfccData = mfccData';
        mfccData = mfccData(1:mfccDimensionSize, :);

        for index_k = 1:length(Phns)

            mfccStartLineIndex = Starts(index_k)/128 + 1;
            mfccEndLineIndex = min(Ends(index_k)/128 + 1, length(mfccData));
            phnKey = char(Phns(index_k));
            if strcmp(phnKey, 'h#')
                phnKey = 'sil';
            end

            if ~isfield(phnData, phnKey)
                phnData.(phnKey) = {};
            end

            %load all phn data into phnDataArray
            phnData.(phnKey){length(phnData.(phnKey))+1} = mfccData(:, mfccStartLineIndex:mfccEndLineIndex);

        end


    end

end

%Task 2: Initialize HMM by Phonemes & Task 3: Train HMM by input data 
PhnToHMMDict = struct();
phnDataKeys = fieldnames(phnData);

for keyIndex = 1:length(phnDataKeys)

    phnDataKey = phnDataKeys{keyIndex};
    PhnToHMMDict.(phnDataKey) = initHMM(phnData.(phnDataKey));
    disp(['Training HMM for Key: ', phnDataKey])
    [PhnToHMMDict.(phnDataKey), LL] = trainHMM(PhnToHMMDict.(phnDataKey), phnData.(phnDataKey));
    disp([num2str(100*keyIndex/length(phnDataKeys)),'% complete'])
end

%Task 4
save( modelOutputName, 'PhnToHMMDict', '-mat');
