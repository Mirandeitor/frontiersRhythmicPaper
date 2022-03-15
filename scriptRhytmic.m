%This script loads the data from the sensors and the manualy coding of the
%rattles and extract the wavelet coherence of the data as well as estimates
%some descriptives based on both the coding and the movement data.

%V1.0 Creation of the document by David Lopez Perez 23.11.2021

%% Load and reduction of the data to the limbs of interest

%Select the parent folder where all the subfolders with the sensor data are
%located
clear all;
parent_directory = uigetdir;
files = dir(parent_directory);
% Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];
% Extract only those that are directories.
subFolders = files(dirFlags);
%Get the names of the folder names and a reduce the number of position for
%further analyses
folderNames = {subFolders.name};
subFolders = subFolders(~ismember(folderNames ,{'.','..','.DS_Store'}));
folderNames = folderNames(~ismember(folderNames ,{'.','..','.DS_Store'}));

%Load the conversion file
for iSub = 1:length(subFolders)
    filesInFolder = dir(strcat(parent_directory,'/',subFolders(iSub,1).name));
    fileNames = {filesInFolder.name};
    filesInFolder = filesInFolder(~ismember(fileNames ,{'.','..','.DS_Store'}));
    for iFile=1:length(filesInFolder)
        data{iSub,iFile} = importdata(strcat(parent_directory,'/',subFolders(iSub).name,'/',filesInFolder(iFile,1).name));
        positions = strfind(filesInFolder(iFile,1).name,'_');
        device{iSub,iFile}  = filesInFolder(iFile,1).name(positions(end)+1:positions(end)+8);
    end
end
%Load the conversion of body parts 
[codes,bodyParts] =  loadCodes_BodyParts(device(1,:))

%Load the body parts to see which one we are gonna use to reduce the data
[values,ok] = listSelectionDialog(bodyParts, {} , 'Select the parts for interest for the analysis' );
listOfSelectedParts = values';
%match the selected parts into
for iSelected = 1:size(listOfSelectedParts,2)
    for iPart = 1:size(bodyParts,2)
        if strcmp(listOfSelectedParts{1,iSelected},bodyParts{1,iPart})
            bodyPartsNumber(iSelected) = iPart;
            break;
        end
    end
end

% Remove the unnecesary data for further processing
device = device(:,bodyPartsNumber);
data = data(:,bodyPartsNumber);

%% Pre-process all the data and generate the average movement signals

% The data is sorted alfabetically -> Firstcolumn Infant Left Arm; Second
% Column Infant Right Arm, Third column is the ParentLeftHand and the last
% column is the ParentRightHand
positions = {};
for iSub = 1:length(subFolders)
    %For each infant we calculate the position of this data to avoid
    %differences in the way the data was exported.    
    for iColumn=1:size(data{iSub,1}.textdata,2)
        switch data{iSub,1}.textdata{end,iColumn}
            case 'Acc_X'              
                [positions(iSub).acceleration] = iColumn-2:1:iColumn;
            case 'Gyr_X'
                [positions(iSub).gyroscope] = iColumn-2:1:iColumn;
            case 'Mag_X'            
                [positions(iSub).magneticField] = iColumn-2:1:iColumn;
        end
    end
    %Remove the structure so can perform the interpolation easier
    for iFile=1:size(data,2)
        dataAux{1,iFile} = data{iSub,iFile}.data;
    end    
    data(iSub,:) = dataAux;

    %% Filter and Interpolate the data %% 
    [frequency(iSub), dataFiltered] = filterSensorData(data(iSub,:),strcat(path,strcat(parent_directory,'/',subFolders(iSub).name,'/',filesInFolder(1,1).name)));    
    dataFiltered_Interpolate(iSub,:) = dataFiltered;
    
end

%Select the plot you want to perform and if you want to compare accelerate
%and quaternion based measures.
[compareAll,movement1D,quaternionDistances] = loadSensorProcessingOptions();

%%Calculate the sensorMovement based on the selected options and
%%filteredData
for iVisit = 1:length(dataFiltered_Interpolate)
%for iVisit = 1:size(dataFiltered_Interpolate,1)
    displacement(iVisit,:) = estimateSensorDisplacement(dataFiltered_Interpolate(iVisit,:),compareAll,movement1D,quaternionDistances,frequency(iVisit),positions(iVisit));
end

%% Load the manual coded data
%Select the parent folder where all the subfolders with the sensor data are
%located
parent_directory_codes = uigetdir;
files_coding = dir(parent_directory_codes);
filesCodingNames = {files_coding.name};
files_coding = files_coding(~ismember(filesCodingNames ,{'.','..','.DS_Store'}));
filesCodingNames = filesCodingNames(~ismember(filesCodingNames ,{'.','..','.DS_Store'}));

%Extract the codes of the coded files
for i = 1:size(filesCodingNames,2)
    filesCodingNamesPositions = strfind(filesCodingNames{i},'_');
    codeInfantCoded{i} = filesCodingNames{i}(1:filesCodingNamesPositions(2)-1);
end

%2.1 Loop through the list of unique codes and load the ones that has sensor data 
for iObs=1:length(folderNames)
    for iObs2 = 1:length(codeInfantCoded)
        positions = strfind(codeInfantCoded{iObs2},folderNames{iObs});
        if isempty(positions)
        	continue;
        else
            [header{iObs}, observerData{iObs}] = loadCodedData(strcat(parent_directory_codes,'/',files_coding(iObs2).name),5)
        	%observerData{iObs} = importdata(strcat(parent_directory_codes,'/',files_coding(iObs2).name));
        end
        clear positions
    end
end

%Reduce the sensor data and the observer data
FinalCodeList = intersect(codeInfantCoded,folderNames); %Find the final data list
FinalCodeList = FinalCodeList(~cellfun(@isempty,observerData));%Reduce the list
folderNames = folderNames(~cellfun(@isempty,observerData));% Find the final sensor list
displacement = displacement(~cellfun(@isempty,observerData),:);%Reduce the sensor data to those available
header = header(~cellfun(@isempty,observerData));
observerData = observerData(~cellfun(@isempty,observerData));%Remove empty cells from the observer data


%2.2 Extract the time series
for iObs=1:length(FinalCodeList)%Hopefully that there are not coded data whose sensor data is not present    
    
    listOfBehaviours{iObs} = unique(observerData{iObs}(:,end));
    %Read the first raw of the file to extract the maximum duration
    positionStartTime = regexp(header{iObs},'duration:') + 9;    
    positionEndTime = regexp(header{iObs},'/');
    positionEndTime(positionEndTime<positionStartTime) = [];
    positionEndTime(2:end) = [];
    totalTime = header{iObs}(positionStartTime:positionEndTime-1);
    totalTime(totalTime==' ')=[];
    [Y,M,D,H,MN,S]=datevec(totalTime);
    totalSeconds = H*3600+MN*60+S;

    %Get the information about the resolution
    positionStartFreq = regexp(header{iObs},'sample:') + 7;    
    positionEndFreq = regexp(header{iObs},'"');    
    positionEndFreq(1) = [];
    resolution = header{iObs}(positionStartFreq:positionEndFreq-1);
    resolution(resolution==' ')=[];
    codingFrequency = str2num(resolution)/1000;

    %Preallocate memory
    totalLength = round(totalSeconds/codingFrequency);
    timeSeriesCoded = zeros([length(listOfBehaviours{iObs}) totalLength]);

    %Step 1 Get the individual behaviours
    for iValue = 1:length(listOfBehaviours{iObs})
        %Find the positions of the behaviour
        fun = cellfun(@(x) isequal(x,listOfBehaviours{iObs}{iValue}),observerData{iObs}(:,end));
        %Columns 2,3 and 4
        selectedTimes = observerData{iObs}(fun,2:3);
        for iTiming=1:size(selectedTimes,1)
            if str2num(selectedTimes{iTiming,1})==0
            	timeSeriesCoded(iValue,1:round(str2num(selectedTimes{iTiming,2})/codingFrequency)) = 1;
            else
                timeSeriesCoded(iValue,round(str2num(selectedTimes{iTiming,1})/codingFrequency):round(str2num(selectedTimes{iTiming,2})/codingFrequency)) = 1;
        	end
        end
    end
    timeCoded{iObs} = timeSeriesCoded;
end


%% Synchronise the manual and the movement time series
%1-. We need to resample 
for iObs=1:length(FinalCodeList)
	resampledTimeSeriesCoded{iObs} = interp1(1:size(timeCoded{iObs},2),timeCoded{iObs}',linspace(1,size(timeCoded{iObs},2),size(displacement{iObs},2)));
end 

%2-. Realign the time series of sensors in relation to the coded data 
%The need for recalculation is returned to add another layer of validation
%in those cases that the alignment didnt work initially
W=300;
saveCorrectedPlots = inputdlg('Do you wanna save the clapping plots for later inspection of the delay estimation?(y/n)')'
for iObs=1:length(FinalCodeList)
    [delay(iObs),positionClapping(iObs),recalculationNeeded{iObs}] = estimateDelay(resampledTimeSeriesCoded{iObs},displacement(iObs,:),listOfBehaviours{iObs},W,[3 4],[],'clap');    
    [resampledTimeSeriesCodedCorrected{iObs},euclideanDLCCorrected{iObs}] = correctForDelay([],resampledTimeSeriesCoded{iObs}',delay(iObs));        
end
%% Extract only those periods of rattling to remove movement "noise" and calculate the "rattling" time series
for iObs=1:length(FinalCodeList)
    %Find the rattles coded data
    for iClap=1:length(listOfBehaviours{iObs})
        if strcmp(listOfBehaviours{iObs}{iClap,1},'')
            break;
        end
    end
    %Crop the time series and create new ones of the infants data
    resampledTimeSeriesCodedCorrected{iObs}(resampledTimeSeriesCodedCorrected{iObs}(:,iClap)~=1,iClap) = 0;
    difference  = diff(resampledTimeSeriesCodedCorrected{iObs}(:,iClap))';
    numberOfRattlingBlocks  = sum(difference==1);
    startPositons = find(difference==1);
    endPositions = find(difference==-1);
    leftHand = [];
    rightHand = []; 
    for iBlock = 1:numberOfRattlingBlocks
        leftHand = [leftHand, displacement{iObs,1}(1,startPositons(iBlock):endPositions(iBlock))];
        rightHand = [rightHand, displacement{iObs,2}(1,startPositons(iBlock):endPositions(iBlock))];
    end
    leftHandTS{iObs} = leftHand;
    rightHandTS{iObs} = rightHand;
    %Categorised around the mean to create time series of rattling periods
    leftHandCategorised{iObs} = categorisedMovementAboveMean(leftHand);
    rightHandCategorised{iObs} = categorisedMovementAboveMean(rightHand);
end
%% Calculate wavelet coherence with and without cropping the data
meanCoherence = {};
meanCoherenceShuffled = {};
for iObs = 1:size(displacement,1)    
    %% Wavelet decomposition (how much coherent are the wavelet spectra between infant)
    [WCOH,WCS,F{iObs}] = wcoherence(leftHandTS{iObs},rightHandTS{iObs},60,'phasedisplaythreshold',0.7);
    meanCoherence{iObs} = mean(WCOH,2);
    %Shuffled Coherence
    [WCOH,WCS,F{iObs}] = wcoherence(leftHandTS{iObs}(randperm(length(leftHandTS{iObs}))),rightHandTS{iObs}(randperm(length(rightHandTS{iObs}))),60);
    meanCoherenceShuffled{iObs} = mean(WCOH,2);
end
temporalMax = max(cellfun(@length, F));

for iObs = 1:size(displacement,1)    
    if length(meanCoherence{iObs}) < temporalMax      
        F{iObs} = interp1(1:length(F{iObs}),F{iObs}',linspace(1,length(F{iObs}),temporalMax));
        meanCoherence{iObs} = interp1(1:length(meanCoherence{iObs}),meanCoherence{iObs}',linspace(1,length(meanCoherence{iObs}),temporalMax));
    end 
    if size(meanCoherence{iObs},1) > size(meanCoherence{iObs},2)
        meanCoherence{iObs} = meanCoherence{iObs}';
    end
    %Shuffle
    if length(meanCoherenceShuffled{iObs}) < temporalMax      
        F{iObs} = interp1(1:length(F{iObs}),F{iObs}',linspace(1,length(F{iObs}),temporalMax));
        meanCoherenceShuffled{iObs} = interp1(1:length(meanCoherenceShuffled{iObs}),meanCoherenceShuffled{iObs}',linspace(1,length(meanCoherenceShuffled{iObs}),temporalMax));
    end 
    if size(meanCoherenceShuffled{iObs},1) > size(meanCoherenceShuffled{iObs},2)        
        meanCoherenceShuffled{iObs} = meanCoherenceShuffled{iObs}';
    end
    %Control for wrong values in the calculations
    meanCoherence{iObs}(isinf(meanCoherence{iObs})) = NaN;
    meanCoherence{iObs}(meanCoherence{iObs}>1) = NaN;
    meanCoherence{iObs}(meanCoherence{iObs}<-1) = NaN;
    meanCoherenceShuffled{iObs}(isinf(meanCoherenceShuffled{iObs})) = NaN;
    meanCoherenceShuffled{iObs}(meanCoherenceShuffled{iObs}>1) = NaN;
    meanCoherenceShuffled{iObs}(meanCoherenceShuffled{iObs}<-1) = NaN;
    meanCoherence{iObs} = 0.5 * (fillmissing(meanCoherence{iObs}, 'previous') + fillmissing(meanCoherence{iObs}, 'next'))
    meanCoherenceShuffled{iObs} = 0.5 * (fillmissing(meanCoherenceShuffled{iObs}, 'previous') + fillmissing(meanCoherenceShuffled{iObs}, 'next'))

end
%% Add some descriptive measures based on coded data (mean duration of rattling periods + number of them)
for iObs=1:length(FinalCodeList)
    
    for iClap = 1:length(listOfBehaviours{iObs})
        if strcmp(listOfBehaviours{iObs}(iClap),'')
            break
        end
    end
    difference  = diff(timeCoded{iObs}(iClap,:));
    %Calculate the number of blocks     
    numberRattlingBlocks(iObs) = sum(difference(difference==1));
    %Calculate the duration
    durationRattling(iObs) = mean(abs([find(difference==1) - find(difference==-1)]*codingFrequency));
    %Number of rattlings
    differenceLeft = diff(leftHandCategorised{iObs});
    differenceRight= diff(rightHandCategorised{iObs});
    numberRattlings(iObs) = round(mean([sum(differenceLeft(differenceLeft==1)) sum(differenceRight(differenceRight==1))])); 
    %Estimate the rattling frequency
    frequencyRattling(iObs) = 1/(length(leftHandCategorised{iObs})/(numberRattlings(iObs)*60));
    
    %MeanCoherece in the range
    meanCoherenceRange(iObs) = nanmean(meanCoherence{iObs}(~(F{1}<.5 | F{1}>2.5)));
    %MeanShuffled coherence
    meanCoherenceRangeShuffled(iObs) = nanmean(meanCoherenceShuffled{iObs}(~(F{1}<.5 | F{1}>2.5)));
end
