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

classdef LambOseenVortexFlow
%LambOseenVortexFlow Class that defines a Lamb-Oseen vortex flow field
%   Detailed explanation goes here

    properties
        maxVelocityPixel
        imSizeX
        imSizeY
        marginsX
        marginsY
        xc
        yc
        dt
        alfa
        circulation
        Weight = 1.0;
        Radius = 100.0;
    end
    methods
        function obj = LambOseenVortexFlow(maxVelocityPixel, dt, imageProperties)
            obj.maxVelocityPixel = maxVelocityPixel;
            obj.dt = dt;
            obj.imSizeX = double(imageProperties.sizeX);
            obj.imSizeY = double(imageProperties.sizeY);
            obj.marginsX = double(imageProperties.marginsX);
            obj.marginsY = double(imageProperties.marginsY);
            obj.alfa = 1.25643;

            obj.yc = (obj.imSizeY-1.0)/2.0;
            obj.xc = (obj.imSizeX-1.0)/2.0;

            c = 1.7148; %c must be re-adjusted if alfa is changed. (obj.Radius * c) is the r at which the vortex
                        %tangential velocity vector euclidian-norm is the highest. c depends on alfa only.
            rmax = obj.Radius * c; 
            obj.circulation = maxVelocityPixel * acos(1.0 - (maxVelocityPixel*dt)^2/(2.0 * rmax^2)) / ...
                (maxVelocityPixel * (1.0/rmax + 1.0/(2.0 * obj.alfa) * obj.Radius / rmax^2) * ...
                (1.0 - exp(-obj.alfa .* rmax^2/obj.Radius^2)) * dt)
        end
        
        function [ x1, y1 ] = computeDisplacementAtImagePosition(obj, x0, y0)
            circulation = obj.circulation;
            y0 = double(y0);
            x0 = double(x0);
            r=sqrt((y0 - obj.yc).^2 + (x0 - obj.xc).^2);
            theta0=atan2((y0 - obj.yc),(x0 - obj.xc));
            
            theta1 = obj.Weight .* circulation .* obj.dt .* ...
                     (1.0./r + 1.0./(2.0 .* obj.alfa) .* obj.Radius ./ r.^2) .* ...
                     (1.0 - exp(-obj.alfa .* r.^2 ./ obj.Radius^2)) + theta0;
            x1 = r .* cos(theta1);
            y1 = r .* sin(theta1);
            
            x1 = x1 + obj.xc;
            y1 = y1 + obj.yc;    
        end
        
        function [name] = getName(~) 
            name = 'Lamb-Oseen Vortex flow';
        end
        
        %function obj = set.Weight(obj, weight)
        %    obj.Weight = weight;
        %end
    end
end
	
