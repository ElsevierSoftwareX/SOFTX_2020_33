%This program generates synthetic PIV images and exports validation data.
%Copyright (C) 2019  Luís Mendes, Prof. Rui Ferreira, Prof. Alexandre Bernardino
%
%This program is free software; you can redistribute it and/or
%modify it under the terms of the GNU General Public License
%as published by the Free Software Foundation; either version 2
%of the License, or (at your option) any later version.
%
%This program is distributed in the hope that it will be useful,
%but WITHOUT ANY WARRANTY; without even the implied warranty of
%MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%GNU General Public License for more details.
%
%You should have received a copy of the GNU General Public License
%along with this program; if not, write to the Free Software
%Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
%
%Special thanks go to Ana Margarida and Rui Aleixo
%and their initial effort on building a draft for a similar tool.

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
            maxVelocity = obj.maxVelocityPixel;
            %Max x coordinate is -1 regarding to imSizeX, because,
            xc = (obj.imSizeX-1)/2.0;
            yc = (obj.marginsY+1)/2.0;

            maxX = (obj.imSizeX-1) - obj.marginsX/2;
            maxY = (obj.imSizeY-1) - obj.marginsY/2;
            
            M = sqrt((maxX-xc)^2+(maxY-yc)^2);
                       
            x1 = exp(maxVelocity .* obj.dt / M) .* (x0-xc) + xc;
            y1 = exp(-maxVelocity  .* obj.dt / M) .* (y0-yc) + yc;
            
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

