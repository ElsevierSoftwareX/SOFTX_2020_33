function [Im0, Im1] = adjustImagesIntensity(pivParameters, Im0, Im1)
%adjustImagesIntensity Adjust images intensity by either clipping
%   or normalizing, based on allowed maximum pixel bit depth.

maxValue = 2^pivParameters.bits-1;
switch pivParameters.intensityMethod   
    case 'normalize'
        maxI = max(max(max(Im0)),max(max(Im1)));        
        if maxI > maxValue 
           Im0 = Im0 .* maxValue ./ maxI;
           Im1 = Im1 .* maxValue ./ maxI;
        end

        Im0 = round(Im0);
        Im1 = round(Im1);
    case 'clip'
        Im0 = round(Im0);
        Im1 = round(Im1);

        Im0(Im0>maxValue) = maxValue;
        Im1(Im1>maxValue) = maxValue;               
    otherwise
        error('Unknown intensity method');
end

if pivParameters.bits == 8
    Im0 = uint8(Im0);
    Im1 = uint8(Im1);
else
    Im0(Im0 > maxValue) = maxValue;
    Im1(Im1 > maxValue) = maxValue;
    Im0 = uint16(Im0);
    Im1 = uint16(Im1);
end
end

