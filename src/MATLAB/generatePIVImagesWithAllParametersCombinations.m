if ~exist('flows','var')
    error('"flows" variable must be set. Defines the flows to generate.');
end
if ~exist('bitDepths','var')
    warning('"bitDepths" variable not defined. Defines the image bit depths.');
    warning('"bitDepths" variable will use default value of single 8-bit depth set.');
    bitDepths=8;
end
if ~exist('Ni','var')
    error('"Ni" variable must be set. Defines the volume particle concentration');
end
if ~exist('deltaXFactor','var')
    error('"deltaXFactor" variable must be set. Defines the IA displacement factors');
end
if ~exist('particleRadius','var')
    error('"particleRadius" variable must be set. Define the particle radiuses (px)');
end
if ~exist('noiseLevel','var')
    error('"noiseLevel" variable must be set. Defines the noise levels in (dB)');
end
if ~exist('outOfPlaneStdDeviation','var')
    error('"outOfPlaneStdDeviation" variable must not be empty');
end
if ~exist('numberOfRuns','var')
    warning('"numberOfRuns" variable not defined using default value of 1.');
    numberOfRuns = 1;
end

if isempty(flows)
    error('"flows" variable must not be empty');
end
if isempty(Ni)
    error('"Ni" variable must not be empty');
end
if isempty(deltaXFactor)
    error('"deltaXFactor" variable must not be empty');
end
if isempty(particleRadius)
    error('"particleRadius" variable must not be empty');
end
if isempty(noiseLevel)
    error('"noiseLevel" variable must not be empty');
end
if isempty(outOfPlaneStdDeviation)
    error('"outOfPlaneStdDeviation" variable must not be empty');
end

if numberOfRuns < length(outOfPlaneStdDeviation)
    warning('Adjusting numberOfRuns to match number of outOfPlaneStdDeviation combinations');
    numberOfRuns = length(outOfPlaneStdDeviation);
end

if ~exist('displayFlowField', 'var')
    warning('"displayFlowField" not set. Using default value of true');
    displayFlowField = true;
end

if ~exist('closeFlowField', 'var')
    warning('"closeFlowField" not set. Using default value of true');
    closeFlowField = true;
end

totalCombinations = size(flows, 2)*length(deltaXFactor)*length(bitDepths)* ...
    length(particleRadius)*length(Ni)*length(noiseLevel)*numberOfRuns;

tStart = tic();

currentCombination=1;
for i=1:size(flows, 2)
    for deltaXFactorIndex=1:length(deltaXFactor)
        for bitResIndex=1:length(bitDepths)
            for particleRadiusIndex=1:length(particleRadius)
                for NiIndex=1:length(Ni)
                    for noiseLevelIndex=1:length(noiseLevel)
                        outOfPlaneStdDeviationIndex = 0;
                        for run = 1:numberOfRuns
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
                            pivParameters.bits = bitDepths(bitResIndex); % 10, 12
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

                            disp(['Generating combination ' num2str(currentCombination) ' of ' num2str(totalCombinations)]);
                            [Im0, Im1, particleMap, flowField] = generatePIVImages(flowParameters, imageProperties, pivParameters, run, displayFlowField, closeFlowField);
                            currentCombination = currentCombination + 1;
                        end
                    end
                end
            end
        end
    end
end

tEnd = toc(tStart);
disp(['Completed all ' num2str(totalCombinations) ' combination(s) in: ' num2str(tEnd) ' seconds']);