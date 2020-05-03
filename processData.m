function xCVal = processData(rawdata)
%Corrects Data by Removing Initial Deformations

%Defines Data Fields:
    datafields = fieldnames(rawdata);    
    nspec = length(datafields);
%Initializes Matrix of Optimized Values:
    xCVal = zeros(nspec,11);
%Removes nan Values:
    for ispec = 1:nspec
        %Assigns Load-Deformation Data:
            e = [0;rawdata.(datafields{ispec}).e]; s = [0;rawdata.(datafields{ispec}).s];
        %Calculates Initial Stiffness:
            [pinit_Ei,indEi] = calcEi(e,s,datafields{ispec},0);
        %Calculates Slip Stiffness:
            pinit_Ey = calcEy(e,s,indEi,0);

%         %Performs Initial Four-Parameter Optimization on Elastic Data to
%         %Determine Value of Initial Modulus of Elasticity:
%             %Calculates Extent of Elastic Data:
%             %(using 0.2% strain offset method)
%                 %Defines Elastic Offset Line:
%                     Offset = 0.2/100;
%                     Eline = pinit_Ei(1).*(e-Offset);
%                 %Determines Index
%                     indElastic = find(s<Eline,1,'first');
%                 %Extracts Elastic Data:
%                     eElastic = e(1:indElastic); sElastic = s(1:indElastic);
%                     [~,sy(ispec)] = intersections(e(indElastic-1:indElastic),s(indElastic-1:indElastic),e(indElastic-1:indElastic),Eline(indElastic-1:indElastic));
%             %Assigns Parameters:
%                 Ei = pinit_Ei(1); Ey = pinit_Ey(1); ry = pinit_Ey(2); ny = 1.5; eo = -(1/2)*(s(1)/Ei);
%             %Performs Optimization:
%                 [xE,fvalE] = FivePOpt(eElastic,sElastic,Ei,Ey,ry,ny,eo,1);
%                 xE./[Ei,Ey,ry,ny,eo]
%             %Stores Optimized Values and Residuals:
%                 xEVal(ispec,:) = [xE,fvalE];
                
        %Performs Four-Parameter Optimization to Initialize Nine-Parameter
        %Optimization: (i.e., four-parameter optimization provides initial
        %conditions for more-advanced nine-parameter optimization)
            %Assigns Parameters:
                Ei = pinit_Ei(1); Ey = pinit_Ey(1); ry = pinit_Ey(2); ny = 1.5;
            %Performs Optimization:
                [xF,~] = FourPOpt(e,s,Ei,Ey,ry,ny,1);
        %Performs Nine-Parameter Optimization:
            %Assigns Parameters:
                Ei = xF(1); Ey = xF(2); ry = xF(3); ny = xF(4); ebr = 17.5/50;
                Eb = xF(2); Ep = xF(1)/20; rb = xF(3); nb = xF(4);
            %Performs Optimization:
                [xC,fvalC,RConval] = NinePOpt(e,s,Ei,Ey,ry,ny,ebr,Eb,Ep,rb,nb,datafields{ispec},1);
            %Stores Optimized Values and Residuals:
                xCVal(ispec,:) = [xC,RConval,fvalC];
                
    end
%Saves Data:
    save('FittedParameters.mat','xCVal');
    
    