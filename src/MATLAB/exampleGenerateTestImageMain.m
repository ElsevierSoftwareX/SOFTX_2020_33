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

clear *; clear GLOBAL *;
close all;

sizeX=512; %Image width without margins
sizeY=512; %Image height without margins

displayFlowField=true; %Display image of each flow field,
closeFlowField=false; %but do not close it automatically

%flows={'rk_uniform' 'rankine_vortex' 'parabolic' 'uniform' 'stagnation',...
%        'shear', 'shear_22d3', 'shear_45d0', 'decaying_vortex'};
flows={'stagnation'};

bitDepths=8;
deltaXFactor=0.25;
particleRadius=1.5;
Ni=6;
noiseLevel=0;
outOfPlaneStdDeviation=0.025;
numberOfRuns=1;

generatePIVImagesWithAllParametersCombinations;
