classdef RankineVortexFlow
%RANKINEVORTEXFLOW Class that defines a Rankine vortex flow field
%   Detailed explanation goes here

    properties
        maxVelocityPixel
        imSizeX
        imSizeY
        marginsY
        dt
        Weight = 1.0;
        Radius = 100.0;
    end
    methods
        function obj = RankineVortexFlow(maxVelocityPixel, dt, imageProperties)
            obj.maxVelocityPixel = maxVelocityPixel;
            obj.dt = dt;
            obj.imSizeX = double(imageProperties.sizeX);
            obj.imSizeY = double(imageProperties.sizeY);
            obj.marginsY = double(imageProperties.marginsY);
        end
        
        function [ x1, y1 ] = computeDisplacementAtImagePosition(obj, x0, y0)
            yc = obj.imSizeY/2 + obj.marginsY/2;
            xc = obj.imSizeX/2 + obj.marginsY/2;
            circulation = obj.maxVelocityPixel / obj.Radius;
            r=sqrt((y0 - yc).^2 + (x0 - xc).^2);
            theta0=atan2((y0 - yc),(x0 - xc));
            
            x1 = zeros(size(x0,1), size(x0,2));
            y1 = zeros(size(x0,1), size(x0,2));
            
            %Inside the forced Vortex Radius            
            if ~isempty(r(r <= obj.Radius))
               theta1 = obj.Weight .* circulation .* obj.dt + theta0(r <= obj.Radius);
               x1(r <= obj.Radius) = r(r <= obj.Radius) .* cos(theta1);
               y1(r <= obj.Radius) = r(r <= obj.Radius) .* sin(theta1);
            end
            
            %Outside the forced Vortex Radius (free vortex)            
            if ~isempty(r(r > obj.Radius))
               theta1 = obj.Weight .* circulation .* obj.dt .* obj.Radius^2 ./ r(r > obj.Radius).^2 + theta0(r > obj.Radius);
               x1(r > obj.Radius) = r(r > obj.Radius) .* cos(theta1);
               y1(r > obj.Radius) = r(r > obj.Radius) .* sin(theta1);
            end
            
            x1 = x1 + xc;
            y1 = y1 + yc;    
        end
        
        function [name] = getName(~) 
            name = 'Rankine Vortex flow';
        end
        
        %function obj = set.Weight(obj, weight)
        %    obj.Weight = weight;
        %end
    end
end
	
