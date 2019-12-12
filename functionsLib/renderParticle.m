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

