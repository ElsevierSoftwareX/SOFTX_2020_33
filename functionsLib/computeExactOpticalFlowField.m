function [U, V] = computeExactOpticalFlowField(imageProperties, flowField)
%computeExactOpticalFlowField Computes the exact optical flow field at the center of
%each image pixel.
%   pivParameters - the PIV parameters
%   imageProperties - the PIV image properties
%   flowField - object defining the current flow field 
%   Returns:
%   U u-component velocities matrix
%   V v-component velocities matrix
    [x0s, y0s] = meshgrid(0:imageProperties.sizeX-1, 0:imageProperties.sizeY-1);
    x0s = double(x0s) + 0.5; %Compute displacement at the center of each pixel
    y0s = double(y0s) + 0.5;

    [x1s, y1s] = flowField.computeDisplacementAtImagePosition(x0s, y0s);

    U = x1s - x0s;
    V = y1s - y0s;
    
    %Discard margins due to the extra IAs, introduced to help reduce the boundary effects.
    leftMargin = ceil(imageProperties.marginsX/2);
    rightMargin = ceil(imageProperties.sizeX - imageProperties.marginsX/2);
    topMargin = ceil(imageProperties.marginsY/2);
    bottomMargin = ceil(imageProperties.sizeY - imageProperties.marginsY/2);
    
    U = U(topMargin+1:bottomMargin, leftMargin+1:rightMargin);
    V = V(topMargin+1:bottomMargin, leftMargin+1:rightMargin);
end

