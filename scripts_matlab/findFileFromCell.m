function desiredPath = findFileFromCell(fileList, desiredString)

  for iNumberOfFiles = 1:size(fileList,1)

    stringIndex = strfind(fileList{iNumberOfFiles}, desiredString);

    if ~isempty(stringIndex)
      desiredPath = fileList{iNumberOfFiles};
    end

  end

end
