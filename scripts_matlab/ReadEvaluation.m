function ISLESEvaluationResults = ReadEvaluation(EVALUATION_DATA_PATH)

delimiter = ',';

formatSpec = '%q%q%q%q%q%q%[^\n\r]';

listing = dir(EVALUATION_DATA_PATH);

inds = [];
n    = 0;
k    = 1;

while n < 2 && k <= length(listing)
    if any(strcmp(listing(k).name, {'.', '..'}))
        inds(end + 1) = k;
        n = n + 1;
    end
    k = k + 1;
end

listing(inds) = [];

nNumberofPatients = size(listing,1);

for iNumberofPatients = 1:nNumberofPatients
    filename = ['/data/data_l63/tsothman/Obelix/Output/Evaluation/Scores_Patient_' num2str(iNumberofPatients)];
    
    fileID = fopen(filename,'r');
    
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
    
    fclose(fileID);
    
    raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
    for col=1:length(dataArray)-1
        raw(1:length(dataArray{col}),col) = dataArray{col};
    end
    numericData = NaN(size(dataArray{1},1),size(dataArray,2));
    
    for col=[1,2,3,4,5,6]
        rawData = dataArray{col};
        for row=1:size(rawData, 1);
            % Create a regular expression to detect and remove non-numeric prefixes and
            % suffixes.
            regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
            try
                result = regexp(rawData{row}, regexstr, 'names');
                numbers = result.numbers;
                
                % Detected commas in non-thousand locations.
                invalidThousandsSeparator = false;
                if any(numbers==',');
                    thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                    if isempty(regexp(numbers, thousandsRegExp, 'once'));
                        numbers = NaN;
                        invalidThousandsSeparator = true;
                    end
                end
                % Convert numeric strings to numbers.
                if ~invalidThousandsSeparator;
                    numbers = textscan(strrep(numbers, ',', ''), '%f');
                    numericData(row, col) = numbers{1};
                    raw{row, col} = numbers{1};
                end
            catch me
            end
        end
    end
    
    scoresAllPatient(iNumberofPatients,1:6) = cell2mat(raw);
end

for i=1:size(scoresAllPatient,2)
    meanScoresAllPatients(1,i) = mean(scoresAllPatient(:,i));
    stdScoresAllPatients(1,i) = std(scoresAllPatient(:,i));
end

ISLESEvaluationResults = [meanScoresAllPatients; stdScoresAllPatients];

end
