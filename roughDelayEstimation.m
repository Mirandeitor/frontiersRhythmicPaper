function delay = roughDelayEstimation(sensorTotal,codedTimeSeries) 

%This function is going provide a rought estimate of the delay between the
%sensorClapping and the manually coded clap. The method will find the
%beginning of each time series, calculate the starting point of each block
%and then average the differences between the beginning of one block and
%the rest. 

% Input: sensorTotal -> the sensor data

%         codedTimeSeries ->  the manually coded time series

% Output: the delay between both time series.

%V1.0 Creation of the document by David Lopez Perez 02.08.2021

%% Validation of the input parameters

if nargin < 1
    error('The sensor data is missing');
end

if nargin < 2
    error('The coded data has not been provided');
end

%% Start the process
blocksInSensorTotal = find(diff([0 sensorTotal'])==1);
blocksInCoded = find(diff([0 codedTimeSeries'])==1);

%If the length is different, launch a warning
if length(blocksInSensorTotal) ~= length(blocksInCoded)
    warning('A different number of blocks has been found. The delay estimate can get affected.');   %Crop the last positions of the longest series
    if length(blocksInSensorTotal) > length(blocksInCoded)
        blocksInSensorTotal(length(blocksInCoded)+1:end) = [];
    else
        blocksInCoded(length(blocksInSensorTotal)+1:end) = [];
    end
end

%Find the difference between delays
delay = round(mean(blocksInSensorTotal - blocksInCoded));
