clc; clear; close all;

%% Loads raw data from stored file:
%   data is organized into Matlab structure named 'rawdata', with one field
%   for each specimen. The data for each specimen consists of
%   e - specimen's engineering strain, e.g., in units of mm/mm or in/in
%   s - specimen's engineering stress, e.g., in units of MPa or ksi
    load('data.mat');
    
%% For each specimen, calls RichardEqFit function to fit Piecewise Richard
%   Equation to engineering stress-strain data 

%Defines Data Fields:
    datafields = fieldnames(data);
    nspec = length(datafields);
    
%For each specimen, performs optimization to fit Richard Equation
%parameters to stress-strain data:
    for ispec = 1:nspec
        if strcmp(datafields{ispec}(1:2),'SF')

            %Assigns Load-Deformation Data:
                e = data.(datafields{ispec}).e; %assigns strain
                s = data.(datafields{ispec}).s; %assigns stress
            %Calls RichardEqFit function:
                RichardEqFit9(e,s,'fmincon',1);
                RichardEqFit8(e,s,'fmincon',1);

        end
            
    end