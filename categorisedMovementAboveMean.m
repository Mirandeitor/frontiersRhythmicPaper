function [categorisedMovement,movAvg] = categorisedMovementAboveMean(movementSeries,aveW,mergT)

%This function is going to convert to 1s and 0s the input time series so it
%can be later used to estimate the delay between the manually coded data
%and the sensor recordings.

%Input: movementSeries -> the sensor measured data
%Output: categorisedMovement -> the categorised version of the data

%V1.0 Creation of the document by David Lopez Perez 05.10.2020
%V1.1 The information about the moving average and the merging time is
%asked to the user by David Lopez Perez 16.11.2020
%V1.2 The information about the moving average and merging time is also
%accepted by the function to asking for information many times when using
%loops by David Lopez Perez 22.12.2020
%V1.3 Now the function returns the moving average used in the function to
%correct the time series later on by David Lopez Perez 20.07.2021

if nargin < 1
    error('The movement time series has not been provided');
end

if nargin <2
    %Ask the user to select the length of the movement average and the window in which individual movements are detected 
    prompt={'Select the moving average length (odd number)','Merging time between behaviours:'};
    name='Automatic Categorisation Values';
    numlines=1;
    defaultanswer={'3','3'};
    answer=inputdlg(prompt,name,numlines,defaultanswer);

    if ~isempty(answer{1,1})
        avgWindow = str2num(answer{1,1});
    else
        avgWindow = 3;
    end

    if ~isempty(answer{2,1})
        mergingTime = str2num(answer{2,1});
    else
        mergingTime = 3;%Assuming 60Hz for now that would be .05 seconds
    end
else
    avgWindow = aveW;
    mergingTime = mergT;
end
%Start the process
movAvg = avgWindow;
moveAveraged = movmean(movementSeries,avgWindow);%~50ms
stdValue = std(movementSeries);
medianValue = median(movementSeries);
categorisedMovement = double(moveAveraged > (median(movementSeries) + std(movementSeries)));

%Join those individual movements that are detected over the merging time
differential = diff(categorisedMovement);
endPositions = find(differential == -1);
startPositions = find(differential == 1);

if size(endPositions,2) < size(startPositions,2)
    %That means that the end is in the very last position
    endPositions(1,end+1) = size(categorisedMovement,2);
end

if size(endPositions,2) > size(startPositions,2)
     %That means that the start is in the very first position
     startPositions(1,2:end+1) = startPositions;
     startPositions(1) = 1;
end

for iEnd = 1:size(endPositions,2)-1
    if (startPositions(iEnd+1) - endPositions(iEnd)) < 	mergingTime
        categorisedMovement(1,endPositions(iEnd):startPositions(iEnd+1)) = 1;
    end
end


