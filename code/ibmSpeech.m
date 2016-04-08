
dir_path = '/u/cs401/speechdata/Testing/';
%d = dir([dir_path, 'unkn_*.flac']);
d = dir([dir_path, 'unkn_*.txt']);
ans = dir([dir_path, '*.txt']);

results = [];
for i=1:length(d)
    command = ['env LD_LIBRARY_PATH='''' curl -u "b659946e-8417-4cb0-a11e-2edf7ec3b94a":"55TXEgL1RuhB" -o "tts_', int2str(i), '.flac" '];
    command = [command, '--header "accept: audio/flac" '];
    command = [command, '"https://stream.watsonplatform.net/text-to-speech/api/v1/synthesize?voice=en-US_LisaVoice&text='];
    
    [SA, EA, refSentence] = textread([dir_path, filesep, 'unkn_', int2str(i), '.txt'], '%d %d %s', 'delimiter', '\n');
    command = [command, urlencode(refSentence), '"'];

    [s, out] = unix(command);


    %Speech -> Text
    unixCommandHeader = 'env LD_LIBRARY_PATH='''' curl -u bf020858-0c11-474b-9860-2fb2ebdc690c:dSSXya1Ebsb2 -X POST';
    unixCommandHeader = [unixCommandHeader, ' --header "Content-Type: audio/flac"'];
    unixCommandHeader = [unixCommandHeader, ' --header "Transfer-Encoding: chunked"'];
    %unixCommandHeader = [unixCommandHeader, ' --data-binary @', dir_path, 'unkn_', int2str(i), '.flac'];
    unixCommandHeader = [unixCommandHeader, ' --data-binary @', 'tts_', int2str(i),'.flac'];
    unixCommandHeader = [unixCommandHeader, ' "https://stream.watsonplatform.net/speech-to-text/api/v1/recognize?continuous=true"'];

    command = unixCommandHeader;

    [s, out] = unix(command);
    data = JSON.parse(out);
    result = data.results{1}.alternatives{1}.transcript;
    results{i} = data.results{1}.alternatives{1}.transcript;
end
fid = fopen('hyp.txt', 'wt');
for i=1:length(results)  
    fprintf(fid, [int2str(0), ' ', int2str(0), ' ', results{i}, '\n']);
end
fclose(fid);

[SE, IE, DE, LEV_DIST] = Levenshtein('hyp.txt',dir_path);