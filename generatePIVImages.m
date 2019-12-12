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

function [ Im0, Im1, particleMap, flowField ] = generatePIVImages( flowParameters, imageProperties, pivParameters, run )
%generatePIVImages Generates a pair of Synthetic PIV images according to specified
%paramteres and properties.
%   flowParameters flow related configuration
%   imageProperties image related properties and px to mm units conversion factor
%   pivParameter PIV related configuration
%   Returns:
%   Im0 the first image of the PIV pair, with randomly placed particles according to configuration
%   Im1 the displaced image of the PIV pair
%   particleMap detailed information about all particles considered for image generation
%   flowField the instantiated flow field object for computing displacements

addpath functionsLib;

tic();

displayFlowField = true;
closeFlowField = true;

outFolder = ['out' filesep createPathNameForTestAndConditions( flowParameters, pivParameters )];
mkdir(outFolder);
minDI = min(pivParameters.lastWindow(1), pivParameters.lastWindow(1));
%Convert maxVelocity from mm/s to px/s and compute adequate dt for the
%deltaXFactor.
flowParameters.maxVelocityPixel = flowParameters.maxVelocity / imageProperties.mmPerPixel;
flowParameters.dt = (minDI * flowParameters.deltaXFactor) / flowParameters.maxVelocityPixel;
disp(['dt=' num2str(flowParameters.dt)]);

flowField = createFlow(flowParameters, imageProperties);
[flowField, particleMap] = createParticles(flowParameters, pivParameters, imageProperties, flowField);
if displayFlowField
    [x0s, y0s] = meshgrid(0:imageProperties.sizeX+imageProperties.marginsX-1,0:imageProperties.sizeY+imageProperties.marginsY-1);
    [x1s, y1s] = flowField.computeDisplacementAtImagePosition(x0s, y0s);
    f = figure;
    us = x1s - x0s;
    vs = y1s - y0s;
    quiver(x0s(1:10:end, 1:10:end), y0s(1:10:end, 1:10:end), us(1:10:end, 1:10:end), vs(1:10:end, 1:10:end));
    title([flowField.getName() ' - ' 'Noise' num2str(pivParameters.noiseLevel, '%02d') ]);
    bytes = figToImStream('figHandle', f, ...
                  'imageFormat', 'jpg', ...
                  'outputType', 'uint8');
    fileID = fopen([ outFolder filesep flowParameters.flowType '_flowField.jpg' ],'w');
    
    fwrite(fileID, bytes);
    
    fclose(fileID);
    if closeFlowField
        close(f);
    end
end
[Im0, Im1] = createImages(pivParameters, imageProperties, particleMap, flowField);
[Im0, Im1] = adjustImagesIntensity(pivParameters, Im0, Im1);

exportFlowFields(flowParameters, pivParameters, imageProperties, particleMap, flowField, outFolder, run);

%Save PIV image
imwrite(Im0, [outFolder filesep flowParameters.flowType num2str(run, '%02d') '_0.tif']);
imwrite(Im1, [outFolder filesep flowParameters.flowType num2str(run, '%02d') '_1.tif']);

toc();

end

