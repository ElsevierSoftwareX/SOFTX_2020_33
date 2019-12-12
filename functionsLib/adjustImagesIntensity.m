%This program generates synthetic PIV images and exports validation data.
%Copyright (C) 2019  Luís Mendes, Prof. Rui Ferreira, Prof. Alexandre Bernardino
%
%This program is free software; you can redistribute it and/or
%modify it under the terms of the GNU General Public License
%as published by the Free Software Foundation; either version 2
%of the License, or (at your option) any later version.
%
%This program is distributed in the hope that it will be useful,
%but WITHOUT ANY WARRANTY; without even the implied warranty of
%MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%GNU General Public License for more details.
%
%You should have received a copy of the GNU General Public License
%along with this program; if not, write to the Free Software
%Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
%
%Special thanks go to Ana Margarida and Rui Aleixo
%and their initial effort on building a draft for a similar tool.

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

