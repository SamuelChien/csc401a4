function [HMMDict] = myTrain(trainDataDir) 
% function [HMMDict] = myTrain(trainDataDir) 
%
%    inputs:
%          trainDataDir	: training directory
%
%     outputs:
%          HMMDict      : Phenome to HMM Dict



HMMDict = struct();

trainDataDir

% DD = dir( [ trainDataDir, filesep, '*', language] );
% disp([ dataDir, filesep, '.*', language] );

% for iFile=1:length(DD)
%     lines = textread([dataDir, filesep, DD(iFile).name], '%s','delimiter','\n');

%     for l=1:length(lines)
%         processedLine =  preprocess(lines{l}, language);
%         words = strsplit(' ', processedLine);

%         %loop through words and construct uni
%         for idx = 1:numel(words)
%             currentField = char(words(idx));

%             %check currentField is valid
%             if strcmp(currentField, ' ') | isempty(currentField) 
%                 continue;
%             %Case True: then add 1
%             elseif isfield(LM.uni, currentField) == 1
%                 LM.uni = setfield(LM.uni, currentField, getfield(LM.uni, currentField) + 1);
%             %Case False: then create a new field
%             else
%                 LM.uni = setfield(LM.uni, currentField, 1);
%             end
%         end
        
%         prevFieldKey = char(words(1));

%         %loop through words and construct dictionary with words
%         for idx = 2:numel(words)
%             currentField = char(words(idx));

%             %check currentField and preFieldKey is valid
%             if strcmp(currentField, ' ') | strcmp(prevFieldKey, ' ') | isempty(currentField) | isempty(prevFieldKey)
%                 continue;

%             %Case True: then check currentField
%             elseif isfield(LM.bi, prevFieldKey) == 1
%                 prevFieldStruct = getfield(LM.bi, prevFieldKey);

%                 %Case True: then add 1
%                 if isfield(prevFieldStruct, currentField) == 1
%                     prevFieldStruct = setfield(prevFieldStruct, currentField, getfield(prevFieldStruct, currentField) + 1);
%                 %Case False: then create a new field
%                 else
%                     prevFieldStruct = setfield(prevFieldStruct, currentField, 1);
%                 end
%                 %Update LM bi
%                 LM.bi = setfield(LM.bi, prevFieldKey, prevFieldStruct);

%             %Case False: then create a new field
%             else
%                 LM.bi = setfield(LM.bi, prevFieldKey, struct());
%             end
%             prevFieldKey = currentField;
%         end
%     end
% end

% save( fn_LM, 'LM', '-mat'); 

return