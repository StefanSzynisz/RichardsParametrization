clc; clear; close all;

%Steel Foam Project

%Defines Toggle to Reload Data:
    tog.reload = 0;
    tog.refit = 0;
    
%Loads Raw Data:
    rawdata = loadData(tog);
%Plots Raw Data:
    plotrawdata(rawdata,0);
%Processes Raw Data:
    if tog.refit
        [xEVal,sy,edata] = processElasticData(rawdata);
        xCVal = processData(rawdata);
    else
        %Loads Results from Five-Parameter Optimization of Elastic Phase of
        %Behavior:
%             load('ElasticParameters.mat');
            load('ElasticParametersSwarmSize300.mat');
        %Loads Results from Nine-Parameter Optimization of Full Behavior:
            load('FittedParameters.mat');
    end
%Plots Processed Data:
%     plotElasticData(edata,xEVal,sy);
%Plots Processed Data:
%     plotProcessedData(rawdata,xCVal);
%Plots Energy Absorption:
    plotEnergyAbsorption(rawdata,xCVal);
    