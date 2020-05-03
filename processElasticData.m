function [xEVal,sy,edata] = processElasticData(rawdata)
%Corrects Data by Removing Initial Deformations

%Defines Data Fields:
    datafields = fieldnames(rawdata);
    nspec = length(datafields);
%Initializes Matrix of Optimized Values:
    xEVal = zeros(nspec,6);
%Initializes Yield Strain and Yield Stress:
    sy = zeros(1,nspec);
%Removes nan Values:
    for ispec = 1:nspec
        %Assigns Load-Deformation Data:
            e = rawdata.(datafields{ispec}).e; s = rawdata.(datafields{ispec}).s;
        %Calculates Initial Stiffness:
            [pinit_Ei,indEi] = calcEi(e,s,datafields{ispec},0);
        %Calculates Slip Stiffness:
            pinit_Ey = calcEy(e,s,indEi,0);

        %Performs Initial Four-Parameter Optimization on Elastic Data to
        %Determine Value of Initial Modulus of Elasticity:
            %Calculates Extent of Elastic Data:
            %(using 0.2% strain offset method)
                %Defines Elastic Offset Line:
                    Offset = 0.2/100;
                    Eline = pinit_Ei(1).*(e-Offset);
                %Determines Index
                    indElastic = find(s<Eline,1,'first');
                %Extracts Elastic Data:
                    edata.(datafields{ispec}).e = e(1:indElastic);
                    edata.(datafields{ispec}).s = s(1:indElastic);
                %Determines Yield Strength by Finding Intersection between
                %Elastic Data and Eline:
                    [~,sy(ispec)] = intersections(e(indElastic-1:indElastic),s(indElastic-1:indElastic),e(indElastic-1:indElastic),Eline(indElastic-1:indElastic));
            %Assigns Parameters:
                e = edata.(datafields{ispec}).e; s = edata.(datafields{ispec}).s;
                Ei = pinit_Ei(1); Ey = pinit_Ey(1); ry = pinit_Ey(2); ny = 1.5; eo = -(1/2)*(s(1)/Ei);
            %Performs Optimization:
                [xE,fvalE] = FivePOpt(e,s,Ei,Ey,ry,ny,eo,1);
            %Stores Optimized Values and Residuals:
                xEVal(ispec,:) = [xE,fvalE];
    end
%Saves Data:
    save('ElasticParameters.mat','xEVal','sy','edata');
    
    