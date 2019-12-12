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

function [ pathName ] = createPathNameForTestAndConditions( flowParameters, pivParameters )
%Helper function for defining output path name
%   Detailed explanation goes here

    pathName = ['Bits' num2str(pivParameters.bits, '%02d') filesep ...        
        'DeltaXFactor' num2str(flowParameters.deltaXFactor, '%1.2f') filesep ...
        'Ni' num2str(pivParameters.Ni, '%02d') filesep ...
        flowParameters.flowType filesep ...
        'ParticleRadius' num2str(pivParameters.particleRadius, '%1.2f') ...
        '_Noise' num2str(pivParameters.noiseLevel, '%02d') ...
        '_Thickness' num2str(pivParameters.laserSheetThickness, '%02d') ...
        '_Deviation' num2str(pivParameters.outOfPlaneStdDeviation, '%1.3f') ];
end

