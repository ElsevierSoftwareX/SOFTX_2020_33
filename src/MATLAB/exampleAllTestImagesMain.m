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

sizeX=512; %Image width without margins
sizeY=512; %Image height without margins

pixelBitDepthsForRun = [ 08 ];
%flows={'rk_uniform' 'rankine_vortex' 'parabolic' 'uniform' 'stagnation'};
flows={'stagnation'};
%deltaXFactor=[0.05 0.10 0.25];
deltaXFactor=[0.25];
particleRadius=[1.0];
%Ni=[ 1 6 12 16];
Ni=[6];
%noiseLevel=[0 5 15]; %10 
noiseLevel=0;

bits=pixelBitDepthsForRun;
outOfPlaneStdDeviation=[0.025 0.05 0.10]; % por cada 1 das 10 runs

for i=1:size(flows, 2)
    for deltaXFactorIndex=1:length(deltaXFactor)
        for bitResIndex=1:length(bits)
            for particleRadiusIndex=1:length(particleRadius)
                for NiIndex=1:length(Ni)
                    for noiseLevelIndex=1:length(noiseLevel)
                        outOfPlaneStdDeviationIndex = 0;
                        for run = 1:10
                            outOfPlaneStdDeviationIndex = outOfPlaneStdDeviationIndex + 1;
                            if outOfPlaneStdDeviationIndex == length(outOfPlaneStdDeviation) + 1
                                outOfPlaneStdDeviationIndex = 1;
                            end
                            clear flowParameters;
                            clear pivParameters;                            
                            clear flowField;
                            clear particleMap;
                            clear Im0;
                            clear Im1;
                            
                            flowParameters={};
                            flowParameters.maxVelocity=1000;     %Maximum velocity in mm/s for both u and v components - 1000.0 mm/s
                            %No particle should displace more than 50% of the interrogation area
                            %linear size (DI). In fact maximum displacement will be 25% of DI.
                            flowParameters.deltaXFactor = deltaXFactor(deltaXFactorIndex); %deltaX/DI up to 0.25, (0.05, 0.10, 0.25), no interest in 0 displacement
                            flowParameters.flowType=flows{i};

                            %dt - 100us - 1000us
                            pivParameters={};
                            pivParameters.bits = bits(bitResIndex); % 10, 12
                            pivParameters.intensityMethod='clip'; %This will clip the values at 8-bit - 10-bit, 12-bit
                                                                  %range
                            %pivParameters.intensityMethod='normalize'; %This will scale down all pixel intensities in both images,
                                                                 %so that the maximum is within the
                                                                 %8bit range
                            pivParameters.renderRadius=20;       %Radius (square) in pixels for rendering a particle
                            pivParameters.particleRadius=particleRadius(particleRadiusIndex);    %Particle radius - 0.5px - 3px 
                            pivParameters.Ni=Ni(NiIndex);        %Particles per PIV last step IA window area   -   1 - 16
                            maxValue = 2^pivParameters.bits-1;
                            pivParameters.particleIntensityPeak=150.0*maxValue/255.0; %Particle intensity at the center of the light sheet (75% a 100%)
                            pivParameters.noiseLevel=noiseLevel(noiseLevelIndex);%30;         %dBW (10 log (V^2)) - 20dBW -> 10 intensity variation
                            pivParameters.lastWindow=[16 16];    %Last PIV Window size (no overlap) - (y;x)
                            pivParameters.laserSheetThickness=2.00; %2mm laser sheet thickness
                            pivParameters.outOfPlaneStdDeviation=outOfPlaneStdDeviation(outOfPlaneStdDeviationIndex); %Out of plane velocity standard devitation in mm/frame (1mm/400us) - 0.025 - 0.05 - 0,10
                            pivParameters.noMoveOutOfIA=false;   %Should particles be allowed to move in/out
                                                                 %of their respective Interrogation Area

                            imageProperties={};
                            imageProperties.marginsX=2*pivParameters.lastWindow(2);
                            imageProperties.marginsY=2*pivParameters.lastWindow(1);
                            imageProperties.sizeX=sizeX + imageProperties.marginsX;
                            imageProperties.sizeY=sizeY + imageProperties.marginsY;
                            imageProperties.mmPerPixel=7.5*10^-2;%For 1.5px particle radius and aprox. 512x512 area size
                            %Adjust scale conversion based on particle size
                            imageProperties.mmPerPixel=imageProperties.mmPerPixel * pivParameters.particleRadius / 1.5;

                            DI = single(pivParameters.lastWindow(1)) * imageProperties.mmPerPixel;
                            dtao = 2.0 * single(pivParameters.particleRadius) * imageProperties.mmPerPixel;
                            pivParameters.c = single(pivParameters.Ni) / (pivParameters.laserSheetThickness * DI^2);
                            pivParameters.Ns = single(pivParameters.Ni)/(4.0/pi*DI/dtao);

                            [Im0, Im1, particleMap, flowField] = generatePIVImages(flowParameters, imageProperties, pivParameters, run);
                        end
                    end
                end
            end
        end
    end
end
