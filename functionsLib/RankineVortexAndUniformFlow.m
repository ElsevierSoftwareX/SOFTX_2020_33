classdef RankineVortexAndUniformFlow
%RankineVortexAndUniformFlow Class that defines a rankine vortex flow field superimposed with a uniform flow field.
%   Detailed explanation goes here

    properties
        maxVelocityPixel
        imSizeX
        imSizeY
        marginsY
        dt
        u
        v
        Weight = 1.0;
        Radius = 100;
    end
    methods
        function obj = RankineVortexAndUniformFlow(maxVelocityPixel, dt, imageProperties)
            obj.maxVelocityPixel = maxVelocityPixel;
            obj.dt = dt;
            obj.imSizeX = double(imageProperties.sizeX);
            obj.imSizeY = double(imageProperties.sizeY);
            obj.marginsY = double(imageProperties.marginsY);
            obj.u = maxVelocityPixel*sqrt(2.0); 
            obj.v = maxVelocityPixel*sqrt(2.0);
        end
        
        function [ x1, y1 ] = computeDisplacementAtImagePosition(obj, x0, y0 )
            circulation = obj.maxVelocityPixel * 2.0 * obj.Radius;
            xc = obj.imSizeX/2.0;
            yc = obj.imSizeY/2.0;

            %Computed with Runge-Kutta numeric method of 4th order
            h = obj.dt / 4.0;
            %
            x1 = zeros(size(x0,1), size(x0,2));
            y1 = zeros(size(x0,1), size(x0,2));
            for i = 1:size(x0,1)
                for j = 1:size(x0,2)
                    %Decide wether the point is in the forced region or
                    %free region
                    xk1 = x0(i,j) - xc;
                    yk1 = y0(i,j) - yc;
                    r = sqrt(xk1.^2 + yk1.^2);                    
                    if r > obj.Radius
                        m = circulation;
                        
                        k1x = - h * ((m * yk1)/(xk1^2 + yk1^2) + obj.u);
                        k1y = h * ((m * xk1)/(xk1^2 + yk1^2) + obj.v);

                        xk2 = xk1 + k1x/2;
                        yk2 = yk1 + k1y/2;
                        k2x = - h * ((m * yk2)/(xk2^2 + yk2^2) + obj.u);
                        k2y = h * ((m * xk2)/(xk2^2 + yk2^2) + obj.v);

                        xk3 = xk1 + k2x/2;
                        yk3 = yk1 + k2y/2;
                        k3x = - h * ((m * yk3)/(xk3^2 + yk3^2) + obj.u);
                        k3y = h * ((m * xk3)/(xk3^2 + yk3^2) + obj.v);

                        xk4 = xk1 + k3x;
                        yk4 = yk1 + k3y;
                        k4x = - h * ((m * yk4)/(xk4^2 + yk4^2) + obj.u);
                        k4y = h * ((m * xk4)/(xk4^2 + yk4^2) + obj.v);

                        x1(i,j) = xk1 + 1/6*(k1x + 2*k2x + 2*k3x + k4x) + xc;
                        y1(i,j) = yk1 + 1/6*(k1y + 2*k2y + 2*k3y + k4y) + yc;
                    else
                        m = circulation / obj.Radius.^2;
                        
                        k1x = - h * ((m * yk1) + obj.u);
                        k1y = h * ((m * xk1) + obj.v);

                        xk2 = xk1 + k1x/2;
                        yk2 = yk1 + k1y/2;
                        k2x = - h * ((m * yk2) + obj.u);
                        k2y = h * ((m * xk2) + obj.v);

                        xk3 = xk1 + k2x/2;
                        yk3 = yk1 + k2y/2;
                        k3x = - h * ((m * yk3) + obj.u);
                        k3y = h * ((m * xk3) + obj.v);

                        xk4 = xk1 + k3x;
                        yk4 = yk1 + k3y;
                        k4x = - h * ((m * yk4) + obj.u);
                        k4y = h * ((m * xk4) + obj.v);

                        x1(i,j) = xk1 + 1/6*(k1x + 2*k2x + 2*k3x + k4x) + xc;
                        y1(i,j) = yk1 + 1/6*(k1y + 2*k2y + 2*k3y + k4y) + yc;
                    end
                end
            end
        end
        
        function [name] = getName(~) 
            name = 'Rankine Vortex with superimposed Uniform flow';
        end
        
        function obj = set.Weight(obj, weight)
            obj.Weight = weight;
        end
    end
end

