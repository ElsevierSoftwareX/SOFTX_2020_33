function [U, V] = computeEstimatedPIVFlowField(pivParameters, imageProperties, particleMap, flowField)
%computeEstimatedPIVFlowField The estimated PIV flow field is exported.
%   PIV results are obtained from the cross-correlation of the particles in the IA, which can vary,
%   based on the initial random position of the particles. This makes the exact PIV velocity vector
%   difficult to compute. Here, instead, the PIV velocity vector is considered to be the displacement
%   seen by a particle placed at the exact center of the respective IA.
%   IA sizes are supposed to be even values. Odd values are not handled properly.
%   Returns:
%   U u-component velocities matrix
%   V v-component velocities matrix 
    U = zeros(particleMap.IAs(1), particleMap.IAs(2));
    V = zeros(particleMap.IAs(1), particleMap.IAs(2));
    %We start at 2, because index is a fake IA just to have particles that
    %can move into the first relevant IA, thus we also end at IAs(1) + 1,
    %since IAs is the true valid IAs number, which doesn't account for the extra.
    for IAi = 2:particleMap.IAs(1)+1
            %Find IA center in x (account margin pixels)
            y0 = double(IAi - 2) * double(pivParameters.lastWindow(1)) + ...
                double(pivParameters.lastWindow(1))/2.0 + double(imageProperties.marginsY)/2.0;
        for IAj = 2:particleMap.IAs(2)+1
            %Find IA center in y (account margin pixels)
            x0 = double(IAj - 2) * double(pivParameters.lastWindow(2)) + ...
                double(pivParameters.lastWindow(2))/2.0 + double(imageProperties.marginsX)/2.0;
            
            [x1, y1] = flowField.computeDisplacementAtImagePosition(x0, y0);
            U(IAi-1, IAj-1) = x1 - x0;
            V(IAi-1, IAj-1) = y1 - y0;
        end
    end
end

