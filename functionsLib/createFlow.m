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
    otherwise        
        error('Unexpected flow type.')
end

end

