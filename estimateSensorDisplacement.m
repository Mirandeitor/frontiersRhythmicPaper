function [displacement, quat_angles] = estimateSensorDisplacement(dataFiltered,compareAll,movement1D,quaternionDistances,frequency,positions)

%This snipplet is going to estimate the movement based on the sensor
%filtered data and options asked to the user.

%Inputs: dataFiltered -> filtered and interpolated sensor data
%        compareAll -> this flag indicates that we want to accelaration
%                      based data and quaternion data
%        movement1D -> if we collapse the 3 coordinates of accelation
%                      measures into 1 common or not
%        quaternionDistance => estimate the data in quaternions format
%        frequency -> the frequency rate of the sensors
%        positions -> columns where the acc,gyr,magnetic data is located
%                     for quaternions analysis.


%Outputs: displacement -> the estimated sensors movement.

% V1.0 Creation of the document by David López Pérez 26.11.2020
% V1.1 The file now wont process anything if the input array is empty. This
%has been added just in case data of one of the sensors is missing by David
%López Pérez 11.08.2021
% V1.2 Performace adjustment. When quaternions and are not needed the Kalman
%filter is no longer applied saving some processing time by David López
%Pérez 12.08.2021
% V1.3 In the quantification of quaternions now the columsn needed for the
% calculation of the data are provided to avoid errors in the data by David
% López Pérez 02.09.2021


%% Validation of the input parameters %%
if nargin < 1
    error('The data has not been provided');
end

if nargin < 2
    compareAll = 0 ;
    movement1D = 0;
    quaternionDistances = 1;
end

if nargin < 3
    movement1D = 0;
    quaternionDistances = 1;    
end

if nargin < 4
    if movement1D
        quaternionDistances = 0; 
    else
        quaternionDistances = 1; 
    end
end

if nargin < 5
    warning('Assuming a frequency of 60hz');
    frequency = 60;
end
%% Start the Process %%
if ~iscell(dataFiltered)
    dataFilteredAux{1} = dataFiltered;
    dataFiltered = dataFilteredAux;
end

%Calculate the quaternion data
for iFile=1:size(dataFiltered,2)
    if ~isempty(dataFiltered{iFile})
        fd.Sensor.Acceleration = dataFiltered{iFile}(:,positions.acceleration);
        fd.Sensor.AngularVelocity = dataFiltered{iFile}(:,positions.gyroscope);
        fd.Sensor.MagneticField = dataFiltered{iFile}(:,positions.magneticField);
        fd.Fs = frequency;%Sensor acquisition rate
        if compareAll || quaternionDistances
            ifilt = ahrsfilter('SampleRate', fd.Fs,'ReferenceFrame', 'ENU');
            for ii=1:size(fd.Sensor.Acceleration,1)
                qahrs(ii) = ifilt(fd.Sensor.Acceleration(ii,:), fd.Sensor.AngularVelocity(ii,:),fd.Sensor.MagneticField(ii,:));
                %[qVector(1) qVector(2) qVector(3) qVector(4)] = parts(qahrs(ii));
            end
        end
        if compareAll
            [quat_Abs_Dist{iFile},quat_angles{iFile}]  = quat_distances(qahrs);
            %Get the Acceleration based data
            %accelerationCorrected = compensateForGravity(qahrs,fd.Sensor.Acceleration);
            %displacement{iFile} = calculateDisplacement(accelerationCorrected,movement1D,frequency);       
            displacement{iFile} = calculateDisplacement(fd.Sensor.Acceleration,1,frequency);       
            correlationBetweenSensors = compareQuaternionAccData(displacement{iFile},quat_Abs_Dist{iFile});
            display(['The correlation between acceleration based and quaternions is: ', num2str(correlationBetweenSensors)]);
        else
            if quaternionDistances
                %Get the Quaternions based data
                [displacement{iFile},quat_angles{iFile}]  = quat_distances(qahrs);
            else
                %Get the Acceleration based data
                %accelerationCorrected = compensateForGravity(qahrs,fd.Sensor.Acceleration);
                %displacement{iFile} = calculateDisplacement(accelerationCorrected,movement1D,frequency);
                displacement{iFile} = calculateDisplacement(fd.Sensor.Acceleration,movement1D,frequency);       
            end
        end
        clear fd qahrs
    else
        displacement{iFile} = [];
    end
end