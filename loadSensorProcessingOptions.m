function [compareAll,movement1D,quaternionDistances] = loadSensorProcessingOptions()

% This snipplet is going to ask for the options to plot the sensorData

% Outputs: compareAll: if we want to compare quaternion and gravitation data
%          movement1D: collapse the acceleration data into one dimension 
%          quaternionDistances: convert the data into quaternions

%V1.0 Creation of the document by David López Pérez 23.11.2020

generateAll = inputdlg({'Do you wanna generate quaternions and gravity correlational measures, (1) yes and (0) no','What type of movement do you choose to plot? (1) for quaternions (0) for gravity based measures'});
if str2num(generateAll{1}) == 1
    compareAll = 1;
    movement1D = 1;
else
    compareAll = 0;
end  
if str2num(generateAll{2}) == 1
	quaternionDistances = 1;
    movement1D = 1;
else
	quaternionDistances = 0;
    movement1D = cell2mat(inputdlg({'Do you want to collapse x,y and z in one dimension? (y/n)'}));
    if strcmp(lower(movement1D),'y')
        movement1D = 1;
    else
        movement1D = 0;
    end
end