function [SE IE DE LEV_DIST] =Levenshtein(hypothesis,annotation_dir)
% Input:
%	hypothesis: The path to file containing the the recognition hypotheses
%	annotation_dir: The path to directory containing the annotations
%			(Ex. the Testing dir containing all the *.txt files)
% Outputs:
%	SE: proportion of substitution errors over all the hypotheses
%	IE: proportion of insertion errors over all the hypotheses
%	DE: proportion of deletion errors over all the hypotheses
%	LEV_DIST: proportion of overall error in all hypotheses

%initialize variables
SE = 0;
IE = 0;
DE = 0;
LEV_DIST = 0;
totalWordCount = 0;
[Starts, Ends, hypSentences] = textread(hypothesis, '%d %d %s', 'delimiter', '\n');


for sentenceIndex = 1:length(Sentences)
	[SA, EA, refSentence] = textread([annotation_dir, filesep, 'unkn_', int2str(sentenceIndex), '.txt'], '%d %d %s', 'delimiter', '\n');

	refSentence = char(refSentence(1));
	hypSentenece = char(hypSentences(sentenceIndex));

	refSentenceList = strread(refSentence,'%s','delimiter', ' ');
	hypSenteneceList = strread(hypSentenece, '%s', 'delimiter', ' ');

	rowSize = length(refSentenceList) + 1;
	columnSize = length(hypSenteneceList) + 1;

	% matrix of distances
	distanceMatrix = zeros(rowSize, columnSize);
	distanceMatrix(:,:) = Inf;
	distanceMatrix(1, 1) = 0;

	% matrix for backtracking
	backtrackingMatrix = zeros(rowSize, columnSize);

	% Fill in distanceMatrix and backtrackMatrix
	for rowIndex=2:rowSize
		for columnIndex=2:columnSize
			del = distanceMatrix(rowIndex-1, columnIndex)+1;
			sub = distanceMatrix(rowIndex-1, columnIndex-1) + ~strcmp(refSentenceList(rowIndex-1), hypSenteneceList(columnIndex-1));
			ins = distanceMatrix(rowIndex, columnIndex-1) + 1;

			distanceMatrix(rowIndex, columnIndex) = min(del, min(sub, ins));

			%Mark del, ins, and sub for backtracking
			if distanceMatrix(rowIndex, columnIndex) == del
				backtrackingMatrix(rowIndex, columnIndex) = 0;
			elseif distanceMatrix(rowIndex,columnIndex) == ins
				backtrackingMatrix(rowIndex,columnIndex) = 1;
			else
				backtrackingMatrix(rowIndex,columnIndex) = 2;
			end
		end
	end

	% Backtraking Operation
	subs_e = 0;
	ins_e = 0;
	del_e = 0;
	while rowSize>1 & columnSize>1
		if backtrackingMatrix(rowSize,columnSize) == 0
			del_e = del_e + 1;
			rowSize = rowSize -1;
		elseif backtrackingMatrix(rowSize,columnSize) == 1
			ins_e = ins_e + 1;
			columnSize = columnSize - 1;
		else
			subs_e = subs_e + ~strcmp(refSentenceList(rowIndex-1), hypSenteneceList(columnIndex-1));
			rowSize = rowSize - 1;
			columnSize = columnSize - 1;
		end
	end

	%Update SE, DE, IE
	SE = SE + subs_e;
	DE = DE + del_e;
	IE = IE + ins_e;
	totalWordCount = totalWordCount + length(refSentenceList);
end

%Average out SE, DE, IE
SE = SE/totalWordCount;
DE = DE/totalWordCount;
IE = IE/totalWordCount;
LEV_DIST = SE + DE + IE;

end
