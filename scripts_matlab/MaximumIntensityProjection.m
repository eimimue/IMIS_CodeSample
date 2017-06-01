function mip = MaximumIntensityProjection(MATRIX)
% Calculate a MIP for every point in time
%
% Input parameters:
% ----------------
% MATRIX: (x,y,z,t) Matrix


% Get maximum intensity projection.
for time = 1:size(MATRIX,4)
	    mip(:,:,time) = max(MATRIX(:,:,:,time), [], 3);
    end


    end
