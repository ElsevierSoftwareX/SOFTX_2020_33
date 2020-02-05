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

function [ Im ] = renderParticle(pivParameters, imageProperties, centerX, centerY, intensity, Im)
%renderParticle Renders a particle at given position (y,x) with ...
% specified central intensity.
%   pivParameters Specific PIV parameters
%   imageProperties Image properties
%   centerX central x particle position
%   centerY central y particle position
%   intensity central particle max. intensisty
%   Im image to superimpose particle
%   Returns:
%   Im the modified matrix with the newly rendered particle.

   d = pivParameters.particleRadius*2.0;
   
   renderRadius = pivParameters.renderRadius;
   
   maxX = min(round(centerX + renderRadius), imageProperties.sizeX);
   minX = max(round(centerX - renderRadius), 1);
   maxY = min(round(centerY + renderRadius), imageProperties.sizeY);
   minY = max(round(centerY - renderRadius), 1);
   
   [xs, ys] = meshgrid(minX:maxX, minY:maxY);
  
   if maxY-minY > 0 && maxX-minX > 0   
       Im(minY:maxY,minX:maxX) = Im(minY:maxY,minX:maxX) + ...
           intensity .* exp(-((double(xs)+0.5-centerX).^2 + (double(ys)+0.5-centerY).^2)./(0.125*d.^2));
   end
end

