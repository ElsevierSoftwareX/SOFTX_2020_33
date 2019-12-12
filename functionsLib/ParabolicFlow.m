classdef ParabolicFlow
%PARABOLICFLOW Class that defines a Parabolic flow field
%   Detailed explanation goes here

    properties
        maxVelocityPixel
        imSizeX
        imSizeY
        marginsY
        dt
        Weight = 1.0;
    end
    methods
        function obj = ParabolicFlow(maxVelocityPixel, dt, imageProperties)
            obj.maxVelocityPixel = maxVelocityPixel;
            obj.dt = dt;
            obj.imSizeX = double(imageProperties.sizeX);
            obj.imSizeY = double(imageProperties.sizeY);
            obj.marginsY = double(imageProperties.marginsY);
        end
        
        function [ x1, y1 ] = computeDisplacementAtImagePosition(obj, x0, y0 )
           circulation = obj.maxVelocityPixel;
           ymin = 1;
           ymax = obj.imSizeY;
           
           x1 = circulation .* (y0 - ymin) .* (y0 - ymax)/((ymax-ymin)/2.0).^2 .* obj.dt + x0;
           y1 = y0;
        end
        
        function [name] = getName(~) 
            name = 'Parabolic flow';
        end
        
        function obj = set.Weight(obj, weight)
            obj.Weight = weight;
        end
    end
end

