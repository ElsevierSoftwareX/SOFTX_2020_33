function [ ] = exportFlowFields(flowParameters, pivParameters, imageProperties, particleMap, flowField, outFolder, run)
%exportFlowFields Computes and exports theortical flow fields for ...
%validation purposes, along with statistical information and initial configurations.
%   Data is exported to a .MAT file.

    [U_OptFlow, V_OptFlow] = computeExactOpticalFlowField(imageProperties, flowField);
    [U_PIV_est, V_PIV_est] = computeEstimatedPIVFlowField(pivParameters, imageProperties, particleMap, flowField);
    [FiIns, FiOuts, FoIns, FoOuts, commonParticles, Rds] = computeFiFoAndRd(pivParameters, imageProperties, particleMap, flowField);
    
    exactOpticalFlowDisplacements={};
    exactOpticalFlowDisplacements.velocities={};
    %In ViPIVIST v is exchanged with u regarding this synthetic generation
    %scripts
    exactOpticalFlowDisplacements.velocities.u = single(U_OptFlow);
    exactOpticalFlowDisplacements.velocities.v = single(V_OptFlow);
    exactOpticalFlowDisplacements.velocities.iaWidth=1;
    exactOpticalFlowDisplacements.velocities.iaHeight=1;
    exactOpticalFlowDisplacements.velocities.margins={};
    exactOpticalFlowDisplacements.velocities.margins.top=0;
    exactOpticalFlowDisplacements.velocities.margins.left=0;
    exactOpticalFlowDisplacements.velocities.margins.bottom=0;
    exactOpticalFlowDisplacements.velocities.margins.right=0;
    exactOpticalFlowDisplacements.parameters={};
    exactOpticalFlowDisplacements.parameters.overlapFactor=1.0;
    %
    estimatedPIVDisplacements={};
    estimatedPIVDisplacements.iaWidth=pivParameters.lastWindow(2);
    estimatedPIVDisplacements.iaHeight=pivParameters.lastWindow(1);
    estimatedPIVDisplacements.u = single(U_PIV_est);
    estimatedPIVDisplacements.v = single(V_PIV_est);
    estimatedPIVDisplacements.margins={};
    estimatedPIVDisplacements.margins.top=0;
    estimatedPIVDisplacements.margins.left=0;
    estimatedPIVDisplacements.margins.bottom=0;
    estimatedPIVDisplacements.margins.right=0;
    estimatedPIVDisplacements.parameters={};
    estimatedPIVDisplacements.parameters.overlapFactor=1.0;
    %
    pivStatistics={};
    pivStatistics.FiIns = single(FiIns);
    pivStatistics.FiOuts = single(FiOuts);
    pivStatistics.FoIns = single(FoIns);
    pivStatistics.FoOuts = single(FoOuts);
    pivStatistics.Rds = single(Rds);
    pivStatistics.commonParticles = single(commonParticles);
    
    save([outFolder filesep flowParameters.flowType '_run' num2str(run, '%02d') '_validation.mat'], 'imageProperties', 'pivParameters', 'flowParameters', 'exactOpticalFlowDisplacements', 'estimatedPIVDisplacements', 'pivStatistics');
end

