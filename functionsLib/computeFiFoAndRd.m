function [FiIns, FiOuts, FoIns, FoOuts, commonParticles, Rds] = computeFiFoAndNs(pivParameters, imageProperties, particleMap, flowField)
%computeFiFoAndRd Computes exact Fi, Fo and Rd parameters
%   Returns:
%   FiIns  - the number of particles that enter each IA in the second image due to a inplane inward movement.
%   FiOuts - the number of particles that leave each IA in the second image due to a inplane outward movement.
%   FoIns  - the number of particles that enter each IA in the second image due to an out-of-plane inward movement.
%   FoOuts - the number of particles that leave each IA in the second image due to an out-of-plane outward movement.
%   commonParticles - the number of particles in each IA that are common to both images
%   Rds    - an estimate of the cross-correlation quality at each IA (for PIV methods only)
    outOfViewZ = pivParameters.laserSheetThickness/2;

    FiIns = zeros(particleMap.IAs(1), particleMap.IAs(2));
    FiOuts = zeros(particleMap.IAs(1), particleMap.IAs(2));
    FoIns = zeros(particleMap.IAs(1), particleMap.IAs(2));
    FoOuts = zeros(particleMap.IAs(1), particleMap.IAs(2));
    Rds = zeros(particleMap.IAs(1), particleMap.IAs(2));
    commonParticles=zeros(particleMap.IAs(1), particleMap.IAs(2));
    for IAi = 2:particleMap.IAs(1)+1        
        topY = (IAi - 2)*pivParameters.lastWindow(2) + imageProperties.marginsY/2;
        bottomY = topY + pivParameters.lastWindow(2);
        for IAj = 2:particleMap.IAs(2)+1
            FiIn = 0;
            FiOut = 0;
            FoIn = 0;
            FoOut = 0;
            commonCount = 0;
            leftX = (IAj - 2)*pivParameters.lastWindow(1) + imageProperties.marginsX/2;
            rightX = leftX + pivParameters.lastWindow(1);
            
            %Check if particles from left IA enter this IA
            particles = particleMap.pivMap{IAi, IAj-1};
            for n = 1:length(particles)
                finalOutOfPlanePosition = particles(n).outOfPlanePosition + particles(n).outOfPlaneMovement;
                [x1,y1] = flowField.computeDisplacementAtImagePosition(particles(n).x, particles(n).y);
                if x1 >= leftX && x1 < rightX && y1 >= topY && y1 < bottomY && ...
                    (outOfViewZ - abs(finalOutOfPlanePosition) >= 0)
                    %Particle only contributes to the error if it is visible
                    %in the last image, when entering the current IA                    
                    FiIn = FiIn + 1;
                end
            end
           
            %Check if particles from right IA enter this IA
            particles = particleMap.pivMap{IAi, IAj+1};
            for n = 1:length(particles)
                finalOutOfPlanePosition = particles(n).outOfPlanePosition + particles(n).outOfPlaneMovement;
                [x1,y1] = flowField.computeDisplacementAtImagePosition(particles(n).x, particles(n).y);
                if x1 >= leftX && x1 < rightX && y1 >= topY && y1 < bottomY && ...
                    (outOfViewZ - abs(finalOutOfPlanePosition) >= 0)
                    %Particle only contributes to the error if it is visible
                    %in the last image, when entering the current IA
                    FiIn = FiIn + 1;
                end
            end
            
            %Check if particles from top IA enter this IA
            particles = particleMap.pivMap{IAi-1, IAj};
            for n = 1:length(particles)
                finalOutOfPlanePosition = particles(n).outOfPlanePosition + particles(n).outOfPlaneMovement;
                [x1,y1] = flowField.computeDisplacementAtImagePosition(particles(n).x, particles(n).y);
                if x1 >= leftX && x1 < rightX && y1 >= topY && y1 < bottomY && ...
                    (outOfViewZ - abs(finalOutOfPlanePosition) >= 0)
                    %Particle only contributes to the error if it is visible
                    %in the last image, when entering the current IA
                    FiIn = FiIn + 1;
                end
            end
            
            %Check if particles from bottom IA enter this IA
            particles = particleMap.pivMap{IAi+1, IAj};
            for n = 1:length(particles)
                [x1,y1] = flowField.computeDisplacementAtImagePosition(particles(n).x, particles(n).y);
                if x1 >= leftX && x1 < rightX && y1 >= topY && y1 < bottomY && ...
                    (outOfViewZ - abs(finalOutOfPlanePosition) >= 0)
                    %Particle only contributes to the error if it is visible
                    %in the last image, when entering the current IA
                    FiIn = FiIn + 1;
                end
            end

            %Check if particles from bottom-left IA enter this IA
            particles = particleMap.pivMap{IAi+1, IAj - 1};
            for n = 1:length(particles)
                [x1,y1] = flowField.computeDisplacementAtImagePosition(particles(n).x, particles(n).y);
                if x1 >= leftX && x1 < rightX && y1 >= topY && y1 < bottomY && ...
                    (outOfViewZ - abs(finalOutOfPlanePosition) >= 0)
                    %Particle only contributes to the error if it is visible
                    %in the last image, when entering the current IA
                    FiIn = FiIn + 1;
                end
            end

            %Check if particles from bottom-right IA enter this IA
            particles = particleMap.pivMap{IAi+1, IAj + 1};
            for n = 1:length(particles)
                [x1,y1] = flowField.computeDisplacementAtImagePosition(particles(n).x, particles(n).y);
                if x1 >= leftX && x1 < rightX && y1 >= topY && y1 < bottomY && ...
                    (outOfViewZ - abs(finalOutOfPlanePosition) >= 0)
                    %Particle only contributes to the error if it is visible
                    %in the last image, when entering the current IA
                    FiIn = FiIn + 1;
                end
            end
            
            %Check if particles from top-left IA enter this IA
            particles = particleMap.pivMap{IAi-1, IAj - 1};
            for n = 1:length(particles)
                [x1,y1] = flowField.computeDisplacementAtImagePosition(particles(n).x, particles(n).y);
                if x1 >= leftX && x1 < rightX && y1 >= topY && y1 < bottomY && ...
                    (outOfViewZ - abs(finalOutOfPlanePosition) >= 0)
                    %Particle only contributes to the error if it is visible
                    %in the last image, when entering the current IA
                    FiIn = FiIn + 1;
                end
            end

            %Check if particles from top-right IA enter this IA
            particles = particleMap.pivMap{IAi-1, IAj + 1};
            for n = 1:length(particles)
                [x1,y1] = flowField.computeDisplacementAtImagePosition(particles(n).x, particles(n).y);
                if x1 >= leftX && x1 < rightX && y1 >= topY && y1 < bottomY && ...
                    (outOfViewZ - abs(finalOutOfPlanePosition) >= 0)
                    %Particle only contributes to the error if it is visible
                    %in the last image, when entering the current IA
                    FiIn = FiIn + 1;
                end
            end

            %Check which particles leave this IA
            particles = particleMap.pivMap{IAi, IAj};
            for n = 1:length(particles)
                initialOutOfPlanePosition = particles(n).outOfPlanePosition;
                finalOutOfPlanePosition = particles(n).outOfPlanePosition + particles(n).outOfPlaneMovement;
                [x1,y1] = flowField.computeDisplacementAtImagePosition(particles(n).x, particles(n).y);
                if x1 < leftX || x1 >= rightX || y1 < topY || y1 >= bottomY
                    if outOfViewZ - abs(initialOutOfPlanePosition) >= 0
                        %Particle was in-plane, but moved outside the current interrogation
                        %window in the second image
                        FiOut = FiOut + 1;
                        if FiOut > pivParameters.Ni
                            error('FiOut is grater than Ni');
                        end
                    end
                elseif outOfViewZ - abs(initialOutOfPlanePosition) >= 0 
                    %Particle is visible in first image (in-plane and
                    %within IA boundaries)
                    if outOfViewZ - abs(finalOutOfPlanePosition) < 0
                        %but is not in the second image (out-of-plane even
                        %if within IA boundaries)
                        FoOut = FoOut + 1;
                    else
                        %Particle is present, both in first and second image, account particle as existing,
                        %but neither contributes to Fi, or Fo.
                        commonCount = commonCount + 1;
                    end
                elseif n <= particleMap.inPlaneParticlesPerIA
                    %Particle is not visible in the first image
                    error('Violates the fixed Ni condition');
                elseif outOfViewZ - abs(finalOutOfPlanePosition) >= 0
                    %Particle is not visible in the first image (inside IA, but out of plane), 
                    %but is in the second image
                    FoIn = FoIn + 1;
                end
            end
            
            FiIns(IAi - 1, IAj - 1) = double(FiIn);
            FiOuts(IAi - 1, IAj - 1) = double(FiOut);
            FoIns(IAi - 1, IAj - 1) = double(FoIn);
            FoOuts(IAi - 1, IAj - 1) = double(FoOut);
            commonParticles(IAi - 1, IAj - 1) = double(commonCount);
        end
    end

    pd = makedist('Normal', 0.0, pivParameters.outOfPlaneStdDeviation);
    deltaZ = icdf(pd, 0.975); % icdf(0.975) - icdf(0.025) = 95%

    Rds = double(pivParameters.Ni) .* ...
          (1.0 - FiOuts ./ double(pivParameters.Ni)) .* ...
          (1.0 - deltaZ ./ pivParameters.laserSheetThickness/2.0);
end

