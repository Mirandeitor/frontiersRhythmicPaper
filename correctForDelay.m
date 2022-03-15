function [resampledTimeSeriesCoded,euclideanDLC] = correctForDelay(euclideanDLC,resampledTimeSeriesCoded,delay,vocalFlag)

%This funtion is going to correct the time series based on the delay
%quantified in the delay estimation method. 

%Inputs: 
    % - euclideanDLC -> is the DLC file containing the automatic movement estimated with Deeplabcut.
    % - resampledTimeSeriesCoded -> the manually coded data
    % - delay -> is the delay found between sensors and coding
    % - vocalFlag -> indicates that the euclideanDLC file is actually vocal
    % data which requires different type of processing


%Outputs:

    % - euclideanDLC -> the corrected Deeplabcut data or vocal data if flag
    % vocal is on
    % - resampledTimeSeriesCoded -< the corrected coded data
    
% V 1.0 Creation of the document by David Lopez Perez 01.08.2021
% V 1.1 Bug Fix validation of the input dimensions has been included by
% David Lopez Perez 12.08.2021
% V 1.2 The function has been extended to accept vocalisation data by David
% Lopez Perez 24.08.2021

%% Validation of the input parameters
if nargin < 1
    error('None of the input parameters have been provided.');
end

if nargin < 2
    error('Only the DLC data has been provided. To be able to correct at least one type of time series and the delay are needed')
end

if nargin < 3
    error('The delay is missing');
end

if size(euclideanDLC,1) < size(euclideanDLC,2)
    euclideanDLC = euclideanDLC';
end

if size(resampledTimeSeriesCoded,1) < size(resampledTimeSeriesCoded,2)
    resampledTimeSeriesCoded = resampledTimeSeriesCoded';
end

if nargin < 4
   vocalFlag = 0;
end


%% Start the process
if ~vocalFlag
    if ~isempty(euclideanDLC) & ~isempty(resampledTimeSeriesCoded)
        if delay > 0
            %Move the Coded and DLC Data to the rigth
            auxiliaryDLC_TS = euclideanDLC;
            auxiliaryDLC_TS(end+1:end+abs(delay),:) = 0;
            auxiliaryDLC_TS = auxiliaryDLC_TS(abs(delay)+1:end,:);   
            euclideanDLC = auxiliaryDLC_TS;
            %Move the DLC Data
            auxiliaryCoded_TS = resampledTimeSeriesCoded(:,:);
            auxiliaryCoded_TS(end+1:end+abs(delay),:) = 0;
            auxiliaryCoded_TS = auxiliaryCoded_TS(abs(delay)+1:end,:);
            resampledTimeSeriesCoded(:,:)  = auxiliaryCoded_TS;
        elseif delay < 0
            %If the delay value is positive we have to move to the left the DLC and coded data
            auxiliaryDLC_TS(1:delay,1:size(euclideanDLC,2)) = 0;
            sizeTCoded = size(euclideanDLC,1);
            auxiliaryDLC_TS = [auxiliaryDLC_TS; euclideanDLC];
            auxiliaryDLC_TS = auxiliaryDLC_TS(1:sizeTCoded,:);
            euclideanDLC = auxiliaryDLC_TS;
            %Move the DLC Data
            auxiliaryCoded_TS(1:delay,1:size(resampledTimeSeriesCoded,2)) = 0;
            sizeTCoded = size(euclideanDLC,1);
            auxiliaryCoded_TS = [auxiliaryCoded_TS; resampledTimeSeriesCoded(:,:)];
            auxiliaryCoded_TS = auxiliaryCoded_TS(1:sizeTCoded,:);
            resampledTimeSeriesCoded(:,:) = auxiliaryCoded_TS;
        end
        clear auxiliaryCoded_TS auxiliaryDLC_TS
    elseif isempty(euclideanDLC) & ~isempty(resampledTimeSeriesCoded)
        if delay < 0
            auxiliaryCoded_TS = resampledTimeSeriesCoded(:,:);
            auxiliaryCoded_TS(end+1:end+abs(delay),:) = 0;
            auxiliaryCoded_TS = auxiliaryCoded_TS(abs(delay)+1:end,:);
            resampledTimeSeriesCoded(:,:)  = auxiliaryCoded_TS;
        elseif delay > 0
            auxiliaryCoded_TS(1:delay,1:size(resampledTimeSeriesCoded,2)) = 0;
            sizeTCoded = size(resampledTimeSeriesCoded,1);
            auxiliaryCoded_TS = [auxiliaryCoded_TS; resampledTimeSeriesCoded(:,:)];
            auxiliaryCoded_TS = auxiliaryCoded_TS(1:sizeTCoded,:);
            resampledTimeSeriesCoded(:,:) = auxiliaryCoded_TS;
        end
    elseif ~isempty(euclideanDLC) & isempty(resampledTimeSeriesCoded)
        if delay < 0
            %Move the Coded and DLC Data to the right
            auxiliaryDLC_TS = euclideanDLC;
            auxiliaryDLC_TS(end+1:end+abs(delay),:) = 0;
            auxiliaryDLC_TS = auxiliaryDLC_TS(abs(delay)+1:end,:);   
            euclideanDLC = auxiliaryDLC_TS;
        elseif delay > 0
            auxiliaryDLC_TS(1:delay,1:size(euclideanDLC,2)) = 0;
            sizeTCoded = size(euclideanDLC,1);
            auxiliaryDLC_TS = [auxiliaryDLC_TS; euclideanDLC];
            auxiliaryDLC_TS = auxiliaryDLC_TS(1:sizeTCoded,:);
            euclideanDLC = auxiliaryDLC_TS;
        end
    end
else
    if ~isempty(euclideanDLC)
         if delay < 0
             for iVocal = 1:length(euclideanDLC)
                %Move the Coded and DLC Data to the right
                auxiliaryVocal = euclideanDLC(iVocal,1).timeSeries;
                auxiliaryVocal(1,end+1:end+abs(delay)) = 0;
                auxiliaryVocal = auxiliaryVocal(1,abs(delay)+1:end);   
                euclideanDLC(iVocal,1).timeSeries = auxiliaryVocal;
             end
        elseif delay > 0
            for iVocal = 1:length(euclideanDLC)
                auxiliaryDLC_TS(1,1:delay) = 0;
                sizeTCoded = size(euclideanDLC(iVocal,1).timeSeries,2);
                auxiliaryDLC_TS = [auxiliaryDLC_TS; euclideanDLC(iVocal,1).timeSeries];
                auxiliaryDLC_TS = auxiliaryDLC_TS(1,1:sizeTCoded);
                euclideanDLC(iVocal,1).timeSeries = auxiliaryDLC_TS;
            end
        end
    else
        warning('The vocal delay correction could not be performed because the data was missing. Returning the same data')
    end
    
end

