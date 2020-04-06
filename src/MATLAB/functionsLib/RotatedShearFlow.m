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

classdef RotatedShearFlow
%RotatedShearFlow Class that defines a generic rotated shear flow field
%   Detailed explanation goes here

    properties
        maxVelocityPixel
        imSizeX
        imSizeY
        marginsY
        marginsX
        alfa
        cosAlfa
        sinAlfa
        dt
        Weight = 1.0;
    end
    methods
        function obj = RotatedShearFlow(alfa, maxVelocityPixel, dt, imageProperties)
            obj.maxVelocityPixel = maxVelocityPixel;
            obj.dt = dt;
            obj.imSizeX = double(imageProperties.sizeX);
            obj.imSizeY = double(imageProperties.sizeY);
            obj.marginsX = double(imageProperties.marginsX);
            obj.marginsY = double(imageProperties.marginsY);
            obj.alfa = alfa;
            obj.cosAlfa = cos(alfa*pi/180.0);
            obj.sinAlfa = sin(alfa*pi/180.0);
        end
        
        function [ x1, y1 ] = computeDisplacementAtImagePosition(obj, x0, y0 )
            if obj.alfa == 0
                yc = obj.marginsY/2.0;
                m = obj.maxVelocityPixel / (obj.imSizeY - obj.marginsY);               

                x1 = m .* (y0 - yc) .* obj.dt + x0;
                y1 = y0;                
            else
                m = obj.maxVelocityPixel/((obj.imSizeY-obj.marginsY)*obj.cosAlfa+(obj.imSizeX-obj.marginsX)*obj.sinAlfa);

                xc = obj.marginsX/2.0;
                yc = obj.marginsY/2.0;

                x1 = m .* ((y0-yc).*obj.cosAlfa + (x0-xc).*obj.sinAlfa).*obj.cosAlfa.*obj.dt + x0;
                y1 = -m .* ((y0-yc).*obj.cosAlfa + (x0-xc).*obj.sinAlfa).*obj.sinAlfa.*obj.dt + y0;                                  
            end
        end
        
        function [name] = getName(obj)
            if (obj.alfa == 0)
                name = 'Shear flow';
            else
                name = ['Rotated Shear flow by ' num2str(obj.alfa, '%3.2f\n') ' degrees'];
            end
        end
        
        function obj = set.Weight(obj, weight)
            obj.Weight = weight;
        end
    end
end

