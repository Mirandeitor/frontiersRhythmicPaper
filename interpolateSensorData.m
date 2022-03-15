function dataInterpolated = interpolateSensorData(inputData,frequency)

%This function is going to interpolate the data from the sensor data to
%remove missing values. Initially a spline inteporlation is done, but in
%the future further expansions can be developed.

%Input: 
    % inputData: The original data 
    % frequency: frequency of the data acquisition
%Ouput: 
    % dataInterpolated: The interpolated and filtereddata.
    
    
% V1.0 Creation of the document by David Lopez Perez 10.10.2020 
% V1.1 Bug Fix the second column normally contains a full list of NaN
% values because it is not sensor-relevant data. Now this is not considered
% for the analysis.
% V1.2 Bug Fix. If there is a column full of Nans, that column is ignored
% by David Lopez Perez 02.10.2020
% V1.3 Now the function allows to send an empty array. In this case the
% data wont be process and an empty array will be returned  by David Lopez
% Perez 10.08.2021
% V1.4 Bug Fix. Previous to interpolation the data was being abs so no
% negative values were present. This has been removed by David Lopez Perez
% 02.09.2021
    
if nargin<1
    error('The data for interpolation has not been provided');
end
    
%Interpolate the data. We remove the 1-2 column because it contains
%irrelevant data that does not need to be interpolated.
if ~isempty(inputData)
    for iColumn = 3:size(inputData,2)
        if all(isnan(inputData(:,iColumn)))
            dataInterpolated(:,iColumn-2) = inputData(:,iColumn);
        else
            %Calculate error between the median filter model and original
            x=inputData(:,iColumn);               
            %Interpolate them using spline interpolation        
            xTime = 1/frequency:1/frequency:1/frequency*size(inputData(:,1));
            %Before interpolating we need to make sure that the last values are
            %not NaN because that can return problems in the interpolation
            if isnan(x(end))
                for iNaN = size(x,1):-1:1
                    if isnan(x(iNaN))
                        continue;
                    else
                        position = iNaN;
                        x(position+1:end,1) = x(position,1);
                        break;                
                    end
                end
            end
            %x = abs(x);        
            x(isnan(x)) = interp1(xTime(~isnan(x)),x(~isnan(x)),xTime(isnan(x)),'spline');
            X_Interpolated = x;
            %Smooth the data a bit using a median filter
            dataInterpolated(:,iColumn-2) = medfilt1(X_Interpolated,3);
            clear errorPartX errorPartY x y position
        end
end
else
    dataInterpolated = [];
end
   