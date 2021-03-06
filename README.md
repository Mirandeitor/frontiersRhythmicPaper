# frontiersRhythmicPaper
This repository contains the Matlab code used in the Frontiers in Psychology paper Longitudinal changes in infants' spontaneous rhythmic arm movements during rattle-shaking play with caregivers


# Data
The data that support the findings will be available upon request from the corresponding authors following an embargo from the date of publication to allow for finalization of the ongoing longitudinal project. 

# Scripts

**Main Script**

- scriptRhytmic.m -> controls the whole process of analysis. The script loads the data from one of the tasks and processes the data using multidimensional RQA on the time series of interest. Particularly: \
      * First select all the infant codes and visits from a parent folder where all the subfolders with the sensor data are located. \
      * Loads a conversion file which main goal is to convert the sensor internal codes to body parts of interest.\
      * Prompt a gui to select which parts are of interest for the analysis and remove unimportant data to save some memory.\
      * Pre-process the data by filtering and interpolating missing data.\
      * Then the movement time series are generated by calculating the the magnitude of the acceleration. \
      * Then there is a synchronisation process that loads the manually coded data from ELAN and synchronise video and sensor based on the parents clapping. 
      * Once the whole synchronisation has been performed the wavelet coherence and the shuffled wavelet conherence are calculated.


**Snipplets**

Here there a series of functions that are called from the main script:

- loadCodes_BodyParts.m -> load the codes and bodyparts from the codingFile (contains body parts to sensor codes conversion) to limit the analysis to certain body parts. 
- filterSensorData.m -> loads the data and return the interpolated and filtered data.
- interpolateSensorData.m -> this function interpolates the data from the sensor data to remove missing values. Initially a spline inteporlation is done, but in the future further expansions can be developed. 
- prepareDataForInterpolation.m -> this function takes an input array and return the data ready for interpolation with the missing values exactly in the place that it should be. 
- loadSensorProcessingOptions.m -> this function asks the user which kind of data will be analysed (quaternions or acceleration).
- estimateSensorDisplacement.m ->  estimate the movement (acc or quaternions) based on the sensor filtered data and options previously asked to the user.
- estimateDelay.m -> return the delay between the coded time series and the sensor time series.
- correctForDelay.m -> corrects video or sensor data time series based on the delay quantified in the delay estimation method. 
- categorisedMovementAboveMean.m -> convert to 1s and 0s the input time series so it can be later used to estimate the delay between the manually coded data and the sensor recordings or to estimate the number of rattlings.
- drpdfromtsCat.m -> explore the cross-recurrence diagonal profile of two-time series to find the delay between them.
- roughDelayEstimation.m -> provide a rought estimate of the delay between the sensorClapping and the manually coded clap. The method will find the beginning of each time series, calculate the starting point of each block and then average the differences between the beginning of one block and the rest. 

# Citations

If you ever use parts of this code for your analysis please cite:

- Lauda??ska, Z., L??pez P??rez,D., Kozio??, A., Radkowska, A., Babis, K.,Malinowska-Korczak, A., Tomalski, P. (2022). Longitudinal changes in infants' spontaneous rhythmic arm movements during rattle-shaking play with caregivers _In Review_.

# Contact

Any missing function  or questions about the code please contact d.lopez@psych.pan.pl

