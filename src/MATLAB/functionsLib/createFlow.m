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

function [ obj ] = createFlow( flowParameters, imageProperties )
%createFlow Factory that instantiates the selected flow field.
%   A flow field object is instantiated according to the specified parameters in flowParameters and imageProperties.
%   Returns:
%   obj the flow field object instance
flowType = lower(flowParameters.flowType);
%NOTE: All flow models work in the image domain thus, here we use pixel
%units for velocity.
switch flowType
    case 'rankine_vortex'
        obj = RankineVortexFlow(flowParameters.maxVelocityPixel, flowParameters.dt, imageProperties);
    case 'parabolic'
        obj = ParabolicFlow(flowParameters.maxVelocityPixel, flowParameters.dt, imageProperties);
    case 'stagnation'
        obj = StagnationFlow(flowParameters.maxVelocityPixel, flowParameters.dt, imageProperties);
    case 'uniform'
        obj = UniformFlow(flowParameters.maxVelocityPixel, flowParameters.dt, imageProperties);
    case 'rk_uniform'
        obj = RankineVortexAndUniformFlow(flowParameters.maxVelocityPixel, flowParameters.dt, imageProperties);
    case 'shear'
        obj = RotatedShearFlow(0, flowParameters.maxVelocityPixel, flowParameters.dt, imageProperties);
    case 'shear_22d3'
        obj = RotatedShearFlow(22.3, flowParameters.maxVelocityPixel, flowParameters.dt, imageProperties);
    case 'shear_45d0'
        obj = RotatedShearFlow(45.0, flowParameters.maxVelocityPixel, flowParameters.dt, imageProperties);        
    case 'decaying_vortex'
        obj = LambOseenLikeVortexFlow(flowParameters.maxVelocityPixel, flowParameters.dt, imageProperties);
    otherwise        
        error(['Unexpected flow type: ''' flowType ''''])
end

end

