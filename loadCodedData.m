function [header,outputData] =  loadCodedData(filename,nrColumns)

%This function is going to split the data from the behaviours data

%V1.0 Creation of the document by David Lopez Perez 25.11.2021
%V1.1 The function has been modified for those cases where there is not a
%single rattling event coded so the function does not fail by David Lopez
%Perez 09.02.2022
%V1.2 The function has been modified to include the number of columns
%automatically so the user doesnt have to do it each time by David López
%Pérez 10.02.2022


fid = fopen(filename)
S = textscan(fid,'%s','delimiter','\n') ;
fclose(fid);
header = S{1}{1,1};
for i=3:length(S{1})
    loadedData{i-2,1} = strsplit(S{1}{i,1},'\t');
end

%Ask for the number of columns
if nargin < 2 || isempty(nrColumns)
    numberOfColumns = inputdlg('Select the number of columns in the coded files');
    if isempty(numberOfColumns)
        numberCol = 5;
    else
        numberCol = str2num(numberOfColumns{1});
    end
else
    numberCol = nrColumns;
end
%Check of the variable loaded data has been created (if the variable 
%doesnt exist it means that the coding file is empty
if exist('loadedData','var')==0
    outputData = {};
else
    outputData = reshape([loadedData{:}],numberCol,size([loadedData{:}],2)/numberCol)';
end