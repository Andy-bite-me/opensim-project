function GRFTz_byLimb = clean_grfs(GRFTz_byLimb, DataRate, CutOffFrequency, tInfo, aTime, vTime)
%% clean_grfs
% This function filters forces data with a 2nd order butterworth filter
% and fits a spline using a number of datam points to match the marker data

%% INPUTS:
% GRFTz_byLimb = the ground reaction force data to be cleaned
% DataRate = rate at which the force data was captured
% CutOffFrequency = cut-off frequency of the butterworth filter

%% OUTPUTS:
% the filtered and data rate matched ground reaction force data

%%

Wn=CutOffFrequency/(DataRate/2);
[B,A]=butter(2,Wn);

for i = tInfo.limb
        filteredFx = filtfilt(double(B),double(A),GRFTz_byLimb.(i{1}).Fx);
        filteredFy = filtfilt(double(B),double(A),GRFTz_byLimb.(i{1}).Fy);
        filteredFz = filtfilt(double(B),double(A),GRFTz_byLimb.(i{1}).Fz);
        filteredTz = filtfilt(double(B),double(A),GRFTz_byLimb.(i{1}).Tz);
        filteredCOPx = filtfilt(double(B),double(A),GRFTz_byLimb.(i{1}).COPx);
        filteredCOPy = filtfilt(double(B),double(A),GRFTz_byLimb.(i{1}).COPy);
        
        % Interpolate filtered data
        GRFTz_byLimb.(i{1}).Fx = interp1(aTime,filteredFx,vTime);
        GRFTz_byLimb.(i{1}).Fy = interp1(aTime,filteredFy,vTime);
        GRFTz_byLimb.(i{1}).Fz = interp1(aTime,filteredFz,vTime);
        GRFTz_byLimb.(i{1}).Tz = interp1(aTime,filteredTz,vTime);
        GRFTz_byLimb.(i{1}).COPx = interp1(aTime,filteredCOPx,vTime);
        GRFTz_byLimb.(i{1}).COPy = interp1(aTime,filteredCOPy,vTime);
        GRFTz_byLimb.(i{1}).startIndex = round(GRFTz_byLimb.(i{1}).startIndex / (length(aTime)/length(vTime)));
        GRFTz_byLimb.(i{1}).stopIndex = round(GRFTz_byLimb.(i{1}).stopIndex / (length(aTime)/length(vTime)));
end

end
    
    
