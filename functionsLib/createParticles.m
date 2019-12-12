function [ flowField, particleMap ] = createParticles(flowParameters, pivParameters, imageProperties, flowField)
%createParticles Creates particles map according to image properties and
%PIV parameters configuration.
%   Particles are randomly distributed with an uniform distribution across the image, 
%   with initial and final light reflection intensities obtained from a normal distribution, 
%   based on particles in-plane position. Out of plane movement is also computed.
%   pivParameters - PIV parameters configuration
%   imageProperties - Image properties
%   Returns:
%   flowField - the same flow field type object that was received at input, but may get some properties modified. Allows flow field properties to be changed if needed, ...
%   for instance callibrate weight factors for the flow field instances.
%   particleMap - the particles map. Contains all information about the generated particles.

    numberIAsX = (imageProperties.sizeX - imageProperties.marginsX) / pivParameters.lastWindow(2);
    numberIAsY = (imageProperties.sizeY - imageProperties.marginsY) / pivParameters.lastWindow(1);

    particleMap = {};
    particleMap.IAs = [numberIAsY, numberIAsX];
    particleMap.pivMap = {};
    particleMap.totalNrParticles = 0;
    particleMap.particles = struct([]);

    %Initialize randomness    
    randn('state', sum(100*clock));
    rand('state', sum(100*clock));
    S=RandStream('mt19937ar','seed','shuffle');

    maxU = 0.0;
    maxV = 0.0;
    %Create intensities values for all particles
    %Particles cannot leave their IA
    inPlaneParticlesPerIA = pivParameters.Ni;
    outOfPlaneParticlesPerIA = 2 * ceil(pivParameters.Ni/pivParameters.laserSheetThickness * 10 * pivParameters.outOfPlaneStdDeviation);
    totalParticlesPerIA = inPlaneParticlesPerIA + outOfPlaneParticlesPerIA;

    particle.x = 0;
    particle.y = 0;
    particle.intensityA = 0;
    particle.intensityB = 0;
    %Create a border of IAs around the relevant IAs
    totalInPlaneNrParticles = inPlaneParticlesPerIA * (numberIAsX + 2) * (numberIAsY + 2);
    totalOutOfPlaneParticles = outOfPlaneParticlesPerIA * (numberIAsX + 2) * (numberIAsY + 2);
    totalNrParticles = totalInPlaneNrParticles + totalOutOfPlaneParticles;
    particleMap.allParticles=repmat(particle, totalNrParticles, 1);
    particleMap.totalNrParticles = totalNrParticles;
    particleMap.inPlaneParticlesPerIA = inPlaneParticlesPerIA;
    particleMap.outOfPlaneParticlesPerIA = outOfPlaneParticlesPerIA;

    particleMap.pivMap = cell(numberIAsY+2, numberIAsX+2);
    particleMap.exactMap = zeros(numberIAsY+2, numberIAsX+2);

    if (numberIAsX + 2)*pivParameters.lastWindow(2) > imageProperties.sizeX
        error('Margins are not wide enough');
    end

    if (numberIAsY + 2)*pivParameters.lastWindow(1) > imageProperties.sizeY
        error('Margins are not tall enough');
    end

    maxDisp = 0;     
    if pivParameters.noMoveOutOfIA
        maxDisp = flowParameters.maxVelocity - floor(pivParameters.particleRadius);
    end
    for iaI = 1:numberIAsY+2
        winTop = (iaI - 2) * pivParameters.lastWindow(1) + ceil(imageProperties.marginsY/2);

        for iaJ = 1:numberIAsX+2            
            winLeft = (iaJ - 2) * pivParameters.lastWindow(2) + ceil(imageProperties.marginsX/2);

            upperX0s = random('unif', winLeft + maxDisp, winLeft + pivParameters.lastWindow(2) - eps - maxDisp, [totalOutOfPlaneParticles/2, 1]);
            upperY0s = random('unif', winTop + maxDisp, winTop + pivParameters.lastWindow(1) - eps - maxDisp, [totalOutOfPlaneParticles/2, 1]);
            x0s = random('unif', winLeft + maxDisp, winLeft + pivParameters.lastWindow(2) - eps - maxDisp, [totalInPlaneNrParticles, 1]);
            y0s = random('unif', winTop + maxDisp, winTop + pivParameters.lastWindow(1) - eps - maxDisp, [totalInPlaneNrParticles, 1]);
            lowerX0s = random('unif', winLeft + maxDisp, winLeft + pivParameters.lastWindow(2) - eps - maxDisp, [totalOutOfPlaneParticles/2, 1]);
            lowerY0s = random('unif', winTop + maxDisp, winTop + pivParameters.lastWindow(1) - eps - maxDisp, [totalOutOfPlaneParticles/2, 1]);

            %Uniformly distributed Particles are also created above and below the lighsheet
            upperParticleOutOfPlanePositions = random('unif', pivParameters.laserSheetThickness/2 + eps, pivParameters.laserSheetThickness/2 + pivParameters.outOfPlaneStdDeviation * 10, [totalOutOfPlaneParticles/2, 1]);
            particleOutOfPlanePositions = random('unif', -pivParameters.laserSheetThickness/2, pivParameters.laserSheetThickness/2, [totalInPlaneNrParticles, 1]);
            lowerParticleOutOfPlanePositions = random('unif', -pivParameters.laserSheetThickness/2 - pivParameters.outOfPlaneStdDeviation * 10, -pivParameters.laserSheetThickness/2 - eps, [totalOutOfPlaneParticles/2, 1]);

            upperIntensitiesA = pivParameters.particleIntensityPeak .* exp(-upperParticleOutOfPlanePositions.^2./(0.125 * pivParameters.laserSheetThickness^2));
            intensitiesA = pivParameters.particleIntensityPeak .* exp(-particleOutOfPlanePositions.^2./(0.125 * pivParameters.laserSheetThickness^2));
            lowerIntensitiesA = pivParameters.particleIntensityPeak .* exp(-lowerParticleOutOfPlanePositions.^2./(0.125 * pivParameters.laserSheetThickness^2));

            upperParticleOutOfPlaneMovement = random('norm', 0, pivParameters.outOfPlaneStdDeviation, [totalOutOfPlaneParticles/2, 1]);
            particleOutOfPlaneMovement = random('norm', 0, pivParameters.outOfPlaneStdDeviation, [totalInPlaneNrParticles, 1]);
            lowerParticleOutOfPlaneMovement = random('norm', 0, pivParameters.outOfPlaneStdDeviation, [totalOutOfPlaneParticles/2, 1]);

            upperIntensitiesB = pivParameters.particleIntensityPeak .* exp(-(upperParticleOutOfPlanePositions+upperParticleOutOfPlaneMovement).^2./(0.125 * pivParameters.laserSheetThickness^2));
            intensitiesB = pivParameters.particleIntensityPeak .* exp(-(particleOutOfPlanePositions+particleOutOfPlaneMovement).^2./(0.125 * pivParameters.laserSheetThickness^2));
            lowerIntensitiesB = pivParameters.particleIntensityPeak .* exp(-(lowerParticleOutOfPlanePositions+lowerParticleOutOfPlaneMovement).^2./(0.125 * pivParameters.laserSheetThickness^2));

            particle.x = 0;
            particle.y = 0;
            particle.intensityA = 0;
            particle.intensityB = 0;
            particle.outOfPlanePosition = 0;
            particle.outOfPlaneMovement = 0;
            particles = repmat(particle, totalParticlesPerIA, 1);
            for n=1:totalParticlesPerIA
                if n  <= inPlaneParticlesPerIA
                    particle={};
                    particle.x = x0s(n);
                    particle.y = y0s(n);
                    particle.intensityA = intensitiesA(n);
                    particle.intensityB = intensitiesB(n);
                    particle.outOfPlanePosition = particleOutOfPlanePositions(n);
                    particle.outOfPlaneMovement = particleOutOfPlaneMovement(n);

                    particles(n) = particle;

                    index = (iaI-1) * (numberIAsX + 2) * totalParticlesPerIA + (iaJ-1) * totalParticlesPerIA + n;
                    particleMap.allParticles(index).x = x0s(n);
                    particleMap.allParticles(index).y = y0s(n);
                    particleMap.allParticles(index).intensityA = intensitiesA(n);                
                    particleMap.allParticles(index).intensityB = intensitiesB(n);
                    particleMap.allParticles(index).outOfPlanePosition = particleOutOfPlanePositions(n);
                    particleMap.allParticles(index).outOfPlaneMovement = particleOutOfPlaneMovement(n);
                elseif n > inPlaneParticlesPerIA && n <= inPlaneParticlesPerIA + outOfPlaneParticlesPerIA/2
                    particle={};
                    particle.x = upperX0s(n - inPlaneParticlesPerIA);
                    particle.y = upperY0s(n - inPlaneParticlesPerIA);
                    particle.intensityA = upperIntensitiesA(n - inPlaneParticlesPerIA);
                    particle.intensityB = upperIntensitiesB(n - inPlaneParticlesPerIA);
                    particle.outOfPlanePosition = upperParticleOutOfPlanePositions(n - inPlaneParticlesPerIA);
                    particle.outOfPlaneMovement = upperParticleOutOfPlaneMovement(n - inPlaneParticlesPerIA);

                    particles(n) = particle;

                    index = (iaI-1) * (numberIAsX + 2) * totalParticlesPerIA + (iaJ-1) * totalParticlesPerIA + n;
                    particleMap.allParticles(index).x = upperX0s(n - inPlaneParticlesPerIA);
                    particleMap.allParticles(index).y = upperY0s(n - inPlaneParticlesPerIA);
                    particleMap.allParticles(index).intensityA = upperIntensitiesA(n - inPlaneParticlesPerIA);                
                    particleMap.allParticles(index).intensityB = upperIntensitiesB(n - inPlaneParticlesPerIA);
                    particleMap.allParticles(index).outOfPlanePosition = upperParticleOutOfPlanePositions(n - inPlaneParticlesPerIA);
                    particleMap.allParticles(index).outOfPlaneMovement = upperParticleOutOfPlaneMovement(n - inPlaneParticlesPerIA);
                else
                    particle={};
                    particle.x = lowerX0s(n - inPlaneParticlesPerIA - outOfPlaneParticlesPerIA/2);
                    particle.y = lowerY0s(n - inPlaneParticlesPerIA - outOfPlaneParticlesPerIA/2);
                    particle.intensityA = lowerIntensitiesA(n - inPlaneParticlesPerIA - outOfPlaneParticlesPerIA/2);
                    particle.intensityB = lowerIntensitiesB(n - inPlaneParticlesPerIA - outOfPlaneParticlesPerIA/2);
                    particle.outOfPlanePosition = lowerParticleOutOfPlanePositions(n - inPlaneParticlesPerIA - outOfPlaneParticlesPerIA/2);
                    particle.outOfPlaneMovement = lowerParticleOutOfPlaneMovement(n - inPlaneParticlesPerIA - outOfPlaneParticlesPerIA/2);

                    particles(n) = particle;

                    index = (iaI-1) * (numberIAsX + 2) * totalParticlesPerIA + (iaJ-1) * totalParticlesPerIA + n;
                    particleMap.allParticles(index).x = lowerX0s(n - inPlaneParticlesPerIA - outOfPlaneParticlesPerIA/2);
                    particleMap.allParticles(index).y = lowerY0s(n - inPlaneParticlesPerIA - outOfPlaneParticlesPerIA/2);
                    particleMap.allParticles(index).intensityA = lowerIntensitiesA(n - inPlaneParticlesPerIA - outOfPlaneParticlesPerIA/2);                
                    particleMap.allParticles(index).intensityB = lowerIntensitiesB(n - inPlaneParticlesPerIA - outOfPlaneParticlesPerIA/2);
                    particleMap.allParticles(index).outOfPlanePosition = lowerParticleOutOfPlanePositions(n - inPlaneParticlesPerIA - outOfPlaneParticlesPerIA/2);
                    particleMap.allParticles(index).outOfPlaneMovement = lowerParticleOutOfPlaneMovement(n - inPlaneParticlesPerIA - outOfPlaneParticlesPerIA/2);
                end
            end

            if pivParameters.noMoveOutOfIA
                [x1s, y1s] = flowField.computeVelocityAtImagePosition(x0s, y0s);
                maxU = max(maxU, max(abs(x1s - x0s)));
                maxV = max(maxV, max(abs(y1s - y0s)));
            end

            particleMap.pivMap{iaI, iaJ} = particles;
        end       
    end

    if pivParameters.noMoveOutOfIA
        maxObservedVelocity = max(maxU, maxV);
        if maxObservedVelocity > flowParameters.maxVelocity
            flowField.Weight = flowParameters.maxVelocity / maxObservedVelocity;
        end
    end
end

