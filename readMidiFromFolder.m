function [X,noteScale,aveDt]=readMidiFromFolder(folderPath,QN,maxLen)
    fileCellArray=dir(folderPath);
    lowestNote=130; highestNote = 0;
    % Do a first pass on all files to find lowest and highest notes
    for i = 1:length(fileCellArray)
        [~,~,EXT] = fileparts(fileCellArray(i).name);
        if (strcmp(EXT,'.mid'))	
            filePath = strcat(folderPath,fileCellArray(i).name);
            midi = readmidi(filePath);
            Notes = midiInfo(midi,0);
            lowNote = min(Notes(:,3)); highNote=max(Notes(:,3));
            if lowNote<lowestNote
                lowestNote=lowNote;
            end
            if highNote>highestNote
                highestNote = highNote;
            end
        end
    end
    X=[];
    noteScale = lowestNote:highestNote;
    aveDt=[]; %holds average time step values
    %second pass to pad matrices and scale tempos
    for i = 1:length(fileCellArray)
        [~,~,EXT] = fileparts(fileCellArray(i).name);
        if (strcmp(EXT,'.mid'))	
            filePath = strcat(folderPath,fileCellArray(i).name);
            midi = readmidi(filePath);
            [Notes,~,aveMicroSPerQN] = midiInfo(midi,0);
            %Use the average microseconds per quarter note to compute the
            %time step between notes to get approx QN # of quarter notes in
            %maxLen number of notes
            ts=(QN*(aveMicroSPerQN/1e6))/maxLen;
            aveDt=[aveDt,ts];
            % compute piano-roll:
            [PR,~,nn] = piano_roll(Notes,0,ts);
            % take only maxLen columns from PR
            featureMat = PR(:,1:maxLen);
            % pad top if necessary
            lowNote=min(nn);
            if lowNote>lowestNote
               featureMat=[zeros(lowNote-lowestNote,maxLen);featureMat]; 
            end
            % pad bottom if necessary
            highNote=max(nn);
            if highNote<highestNote
                featureMat=[featureMat;zeros(highestNote-highNote,maxLen)];
            end
            % convert to vector and add to X
            X=[X;featureMat(:)'];
        end
    end
    aveDt=mean(aveDt);
end