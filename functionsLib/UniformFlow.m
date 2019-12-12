classdef UniformFlow
%UNIFORMFLOW Class that defines a uniform flow field
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
        function obj = UniformFlow(maxVelocityPixel, dt, imageProperties)
            obj.maxVelocityPixel = maxVelocityPixel;
            obj.dt = dt;
            obj.imSizeX = double(imageProperties.sizeX);
            obj.imSizeY = double(imageProperties.sizeY);
            obj.marginsY = double(imageProperties.marginsY);            
        end
        
        function [ x1, y1 ] = computeDisplacementAtImagePosition(obj, x0, y0)
            m=ones(size(x0, 1), size(x0, 2));
            x1 = m .* obj.maxVelocityPixel .* obj.dt + x0;
            y1 = m .* 0.0 + y0;
        end

        function [name] = getName(~) 
            name = 'Uniform flow';
        end
        
        function obj = set.Weight(obj, weight)
            obj.Weight = weight;
        end
    end
end

