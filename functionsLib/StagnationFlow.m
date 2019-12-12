classdef StagnationFlow
%STAGNATIONFLOW Class that defines a stagnation flow field
%   Detailed explanation goes here

    properties
        maxVelocityPixel
        imSizeX
        imSizeY
        marginsY
        marginsX
        dt
        Weight = 1.0;
    end
    methods
        function obj = StagnationFlow(maxVelocityPixel, dt, imageProperties)
            obj.maxVelocityPixel = maxVelocityPixel;
            obj.dt = dt;
            obj.imSizeX = double(imageProperties.sizeX);
            obj.imSizeY = double(imageProperties.sizeY);
            obj.marginsX = double(imageProperties.marginsX);
            obj.marginsY = double(imageProperties.marginsY);
        end
        
        function [ x1, y1 ] = computeDisplacementAtImagePosition(obj, x0, y0 )
            circulation = obj.maxVelocityPixel;
            xc = obj.imSizeX/2.0;
            yc = obj.marginsY/2.0;
                       
            x1 = exp(circulation .* obj.dt / (obj.imSizeX + obj.marginsX)/2) .* (x0-xc) + xc;
            y1 = exp(-circulation  .* obj.dt / (obj.imSizeY + obj.marginsY/2)) .* (y0-yc) + yc;
            
            y1(y0 < yc) = y0(y0 < yc);
            x1(y0 < yc) = x0(y0 < yc);
        end
        
        function [name] = getName(~) 
            name = 'Stagnation flow';
        end
        
        function obj = set.Weight(obj, weight)
            obj.Weight = weight;
        end
    end
end

