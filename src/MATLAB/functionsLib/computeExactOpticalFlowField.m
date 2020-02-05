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

function [U, V] = computeExactOpticalFlowField(imageProperties, flowField)
%computeExactOpticalFlowField Computes the exact optical flow field at the center of
%each image pixel.
%   pivParameters - the PIV parameters
%   imageProperties - the PIV image properties
%   flowField - object defining the current flow field 
%   Returns:
%   U u-component velocities matrix
%   V v-component velocities matrix
    [x0s, y0s] = meshgrid(0:imageProperties.sizeX-1, 0:imageProperties.sizeY-1);
    x0s = double(x0s) + 0.5; %Compute displacement at the center of each pixel
    y0s = double(y0s) + 0.5;

    [x1s, y1s] = flowField.computeDisplacementAtImagePosition(x0s, y0s);

    U = x1s - x0s;
    V = y1s - y0s;
    
    %Discard margins due to the extra IAs, introduced to help reduce the boundary effects.
    leftMargin = ceil(imageProperties.marginsX/2);
    rightMargin = ceil(imageProperties.sizeX - imageProperties.marginsX/2);
    topMargin = ceil(imageProperties.marginsY/2);
    bottomMargin = ceil(imageProperties.sizeY - imageProperties.marginsY/2);
    
    U = U(topMargin+1:bottomMargin, leftMargin+1:rightMargin);
    V = V(topMargin+1:bottomMargin, leftMargin+1:rightMargin);
end

