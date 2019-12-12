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

function [Im0, Im1] = createImages(pivParameters, imageProperties, particleMap, flowField)
%createImages Creates a pair of PIV images for the theoretical flow field,
%given the particles position map, as well as, image and PIV parameters.
%   Returns:
%   Im0 - the initial image with particles at their initial random placement
%   Im1 - the final image with particles at their final locations, i.e., after displacements in-plane and out-of-plane are applied.

    Im0 = zeros([imageProperties.sizeY, imageProperties.sizeX]);
    Im1 = zeros([imageProperties.sizeY, imageProperties.sizeX]);
    
    for n=1:length(particleMap.allParticles)
       x = particleMap.allParticles(n).x;
       y = particleMap.allParticles(n).y;
       intensityA = particleMap.allParticles(n).intensityA;
       [x1, y1] = flowField.computeDisplacementAtImagePosition(x, y);
       displacedX = x1;
       displacedY = y1;
       Im0 = renderParticle(pivParameters, imageProperties, x, y, intensityA, Im0);
       intensityB = particleMap.allParticles(n).intensityB;
       Im1 = renderParticle(pivParameters, imageProperties, displacedX, displacedY, intensityB, Im1);
    end
    
    leftMargin = ceil(imageProperties.marginsX/2);
    rightMargin = ceil(imageProperties.sizeX - imageProperties.marginsX/2);
    topMargin = ceil(imageProperties.marginsY/2);
    bottomMargin = ceil(imageProperties.sizeY - imageProperties.marginsY/2);
    
    Im0 = Im0(topMargin+1:bottomMargin, leftMargin+1:rightMargin);
    Im1 = Im1(topMargin+1:bottomMargin, leftMargin+1:rightMargin);
    
    if pivParameters.noiseLevel > 0
        %generate white noise
        maxValue = 2^pivParameters.bits-1;
        noiseIm0=wgn(imageProperties.sizeY - imageProperties.marginsY, ...
            imageProperties.sizeX - imageProperties.marginsX, pivParameters.noiseLevel);
        noiseIm1=wgn(imageProperties.sizeY - imageProperties.marginsY, ...
            imageProperties.sizeX - imageProperties.marginsX, pivParameters.noiseLevel);
        
        noiseIm0 = noiseIm0 .* maxValue / 255.0;
        noiseIm1 = noiseIm1 .* maxValue / 255.0;
        
        Im0 = Im0 + noiseIm0;
        Im1 = Im1 + noiseIm1;
    end
end
