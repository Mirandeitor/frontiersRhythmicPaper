function [profile,maxrec,maxlag] = drpdfromtsCat(t1,t2,ws)

%Quick method to explore the cross-recurrence diagonal profile of two-time series. 
%It returns the recurrence observed for different delays profile, 
%the maximal recurrence observed maxrec, and the delay at which it occurred (maxlag).

%Based on the R function of the R.Dale and M.Coco
% https://cran.r-project.org/web/packages/crqa/crqa.pdf

%Creation of the document by David Lopez 
%V 1.1 Time series of different length are accepted by David Lopez
%V 1.0 Creation of the document 22.12.2016
 
%Check input variables
if nargin<3
    warning('The window size has not been added. ws = 50 specified by default');
    
end

if nargin<1 || (isempty(t2)&&isempty(t1))
   error('At least one time series has to be provided');
end 

if isempty(t2)
    warning('The time series t2 is empty. t1 will be used to calculate the profile');
    t2 = t1;
end

if isempty(t1)
    warning('The time series t1 is empty. t2 will be used to calculate the profile');
    t1 = t2;
end

%Check the length of both time series and if they are different, shorten
%the longest one
if size(t1,2) == size(t2,2)
elseif size(t1,2) > size(t2,2)
    t1(1,(size(t2,2)+1):(size(t1,2))) = 99;%Shorten T2
    t1(t1==99) = [];
else
    t2(1,(size(t1,2)+1):(size(t2,2))) = 99;%Shorten T2
    t2(t2==99) = [];
end
    

%At the moment the function  has been adapted only for categorical data.
%Datatype = continuous 
datatype = 'categorical';
drpd = [];
%Negative window values
for i=(-ws-1):-2
    ix = abs(i);
    y = t2(ix:length(t2));
    x = t1(1:length(y));
    if strcmp(datatype,'categorical') 
    	drpd(end+1) = sum(y == x)/length(y);
    end
end
%Main Diagonal
if strcmp(datatype,'categorical')
    drpd(end+1) = sum(t1 == t2)/length(t1);
end
%Positive window values
for i=2:(ws+1)
	x = t1(i:length(t1));
    y = t2(1:length(x));
    if strcmp(datatype,'categorical')
    	drpd(end+1) = sum(y == x)/length(y);
    end
end

maxrec = max(drpd);
maxlag = find(drpd == maxrec);
profile = drpd;