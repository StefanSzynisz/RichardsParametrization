function plotElasticData(edata,xEVal,sy)

% %Defines Units:
% %(Choices are 'english' or 'metric')
%     units.type = 'metric';
% %Defines Unit Conversions:
%     switch units.type
%         case{'metric','Metric'}
%             units.length = 25.4; %Converts in to mm
%             units.force = 4.44822159999924; %Converts kip to kN
%             units.stiffness = units.force/(units.length/1000); %kN/m
%             units.stress = 6.89475728001037; %ksi to MPa
%         case{'english','English'}
%             units.length = 1.0; %in defined as natural length unit
%             units.force = 1.0; %kip defined as natural force unit
%             units.stiffness = 1.0;
%             units.stress = 1.0;
%         otherwise
%             error('''%s'' is not an available unit type. Choices are ''english'' and ''metric''');
%     end
    
%Defines Data Fields:
    datafields = fieldnames(edata);    
    nspec = length(datafields);
%Extracts Information from Variable Names:
    %Test Temperature:
        %Initializes Vector of Test Temperatures:
            itemp = zeros(1,nspec);
        %Constructs Vector of Test Temperatures:
            for ispec = 1:nspec
                %Extracts Inidices Bounding Test Temperature:
                    ind1 = strfind(datafields{ispec},'T');
                    ind2 = strfind(datafields{ispec},'C');
                %Stores Test Temperature:
                    itemp(ispec) = str2double(datafields{ispec}(ind1+1:ind2-1));
            end
    %Exposure:
        %Initializes Vector of Exposure Times:
            expos = zeros(1,nspec);
        %Constructs Vector of Exposure Times:
            for ispec = 1:nspec
                %Extracts Inidices Bounding Test Temperature:
                    ind1 = strfind(datafields{ispec},'C');
                %Stores Test Temperature:
                    if itemp(ispec) == 24
                        expos(ispec) = 0;
                    else
                        expos(ispec) = str2double(datafields{ispec}(ind1+2:ind1+3));
                    end
            end
    %Specimen Type:
        %Initializes Type Indices:
            indSF = []; indAF = [];
        %Differentiates Data by Type:
            for ispec = 1:nspec
                spectype{ispec} = datafields{ispec}(1:2); %#ok<AGROW>
                if strcmp(spectype{ispec},'SF')
                    indSF = [indSF,ispec]; %#ok<AGROW>
                else
                    indAF = [indAF,ispec]; %#ok<AGROW>
                end
            end


%Calculates Vector of Ambient-Temperature Parameters:
    xEAmb = xEVal(4,:); syAmb = sy(4); 
%Initializes Figures:
    fig.EiSF = figure('name','Retained Quasi-Elastic Modulus (Steel Foam)','units','inches','position',[1.5,1.75,5.5,3.75],'paperposition',[1.5,1.75,5.5,3.75]); ax = gca;
    fig.sySF = figure('name','Retained Yield Strength (Steel Foam)','units','inches','position',[1.5,1.75,5.5,3.75],'paperposition',[1.5,1.75,5.5,3.75]); ax = gca;
%Plots Elastic Data for Steel Foam:
    for ispec = indSF
        %Unpacks Data:
            %Load-Deformation Data:
                e = edata.(datafields{ispec}).e;
                s = edata.(datafields{ispec}).s;
            %Initial Elastic, Plastic Modulus, and Initial and Final
            %Densification Modulus: xCVal = [ki,ky,ry,ny,dbr,kb,kp,rb,nb,RConval,fvalC];
                EiRet = xEVal(ispec,1)/xEAmb(1);
                EiRET(ispec)=EiRet;
                syRet = sy(ispec)/syAmb;
                SyRET(ispec)=syRet;
        %Selects Relavent Markertype and Color:
            msizefact = 3.0;
            if expos(ispec) == 0
                mtype = 'd'; mcol = ax.ColorOrder(4,:); mfcol = 0.75*ax.ColorOrder(4,:); msize = 155/msizefact;
            elseif expos(ispec) == 15
                mtype = 'o'; mcol = ax.ColorOrder(1,:); mfcol = 0.75*ax.ColorOrder(1,:); msize = 160/msizefact;
            else
                mtype = 's'; mcol = ax.ColorOrder(2,:); mfcol = 0.75*ax.ColorOrder(2,:); msize = 250/msizefact;
            end
        %Defines Indices for Plot Handles According to Exposre:
            if expos(ispec)==15; iexpos = 2; elseif expos(ispec)==30; iexpos = 3; else; iexpos = 1; end
        %Plots Retained Quasi-Elastic Modulus:
            figure(fig.EiSF); ax = gca; %Selects Figure
%             hSF_Ei(iexpos) = scatter(itemp(ispec),EiRet,msize,mtype,'markeredgecolor',mcol,'markerfacecolor',mfcol,'markerfacealpha',0.50,'linewidth',1.0); hold all;
            hSF_Ei(iexpos) = scatter(itemp(ispec),EiRet,msize,mtype,'markeredgecolor','k','markerfacecolor','w','markerfacealpha',0.00,'linewidth',1.0); hold all;
            if ispec == indSF(end)
%                 ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [0.90,3.00];
%                 ax.FontSize = 11;
%                 xlabel('Temperature (°C)','fontsize',12);
%                 ylabel('Retained Quasi-Elastic Modulus','fontsize',12);
%                 hleg = legend(hSF_Ei,{sprintf('Ambient Temperature\n(No Exposure)'),'15 min Exposure','30 min Exposure'},'location','northeast');
%                 grid on; box on; drawnow;
%                 print(fig.EiSF,'EiSF','-dmeta');
                set(ax,'DefaultAxesColorOrder',[0,0,0]);
                set(ax,'DefaultAxesLineStyleOrder','-|s|o|x|v|>|p|d|:s|:o|:x|:v|:>|:p');
                set(ax, 'DefaultLineLineWidth',1.5);
                set(ax,'DefaultLineMarkerSize',5.0);
                ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [0.90,3.00];
                set(gca,'FontSize',12);
                hleg = legend(hSF_Ei,{sprintf('Ambient Temperature\n(No Exposure)'),'15 min Exposure','30 min Exposure'},'location','northeast');
                set(hleg,'FontSize',12,'box','on');   %set legend edges to white
                xlabel('Temperature (°C)','fontname','arial','fontsize',12);
                ylabel('Retained Quasi-Elastic Modulus','fontname','arial','fontsize',12);
                set(gca,'Box','on','TickDir','in','XGrid','off','YGrid','off','XColor',[.0 .0 .0],'YColor',[.0 .0 .0],'LineWidth',1);
                savefig(fig.EiSF,'TemplateFigs/Fig13a.fig')
                print(fig.EiSF,'TemplateFigs/Fig13a','-dmeta');
                print(fig.EiSF,'TemplateFigs/Fig13a','-deps2');
                print(fig.EiSF,'TemplateFigs/Fig13a','-dpdf');
            end
        %Plots Retained Yield Strength:
            figure(fig.sySF); ax = gca; %Selects Figure
%             hSF_sy(iexpos) = scatter(itemp(ispec),syRet,msize,mtype,'markeredgecolor',mcol,'markerfacecolor',mfcol,'markerfacealpha',0.50,'linewidth',1.0); hold all;
            hSF_sy(iexpos) = scatter(itemp(ispec),syRet,msize,mtype,'markeredgecolor','k','markerfacecolor','w','markerfacealpha',0.00,'linewidth',1.0); hold all;
            if ispec == indSF(end)
%                 ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [0.00,1.05];
%                 ax.FontSize = 11;
%                 xlabel('Temperature (°C)','fontsize',12);
%                 ylabel('Retained Yield Strength','fontsize',12);
%                 hleg = legend(hSF_sy,{sprintf('Ambient Temperature\n(No Exposure)'),'15 min Exposure','30 min Exposure'},'location','southwest');
%                 grid on; box on; drawnow;
%                 print(fig.sySF,'sySF','-dmeta');
                set(ax,'DefaultAxesColorOrder',[0,0,0]);
                set(ax,'DefaultAxesLineStyleOrder','-|s|o|x|v|>|p|d|:s|:o|:x|:v|:>|:p');
                set(ax, 'DefaultLineLineWidth',1.5);
                set(ax,'DefaultLineMarkerSize',5.0);
                ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [0.00,1.05];
                set(gca,'FontSize',12);
                hleg = legend(hSF_sy,{sprintf('Ambient Temperature\n(No Exposure)'),'15 min Exposure','30 min Exposure'},'location','southwest');
                set(hleg,'FontSize',12,'box','on');   %set legend edges to white
                xlabel('Temperature (°C)','fontname','arial','fontsize',12);
                ylabel('Retained Yield Strength','fontname','arial','fontsize',12);
                set(gca,'Box','on','TickDir','in','XGrid','off','YGrid','off','XColor',[.0 .0 .0],'YColor',[.0 .0 .0],'LineWidth',1);
                savefig(fig.sySF,'TemplateFigs/Fig9a.fig')
                print(fig.sySF,'TemplateFigs/Fig9a','-dmeta');
                print(fig.sySF,'TemplateFigs/Fig9a','-deps2');
                print(fig.sySF,'TemplateFigs/Fig9a','-dpdf');
            end

    end
    fprintf('Fig17(a):\n');
    itemp(indSF),EiRET(indSF),expos(indSF)
    fprintf('Fig13(a):\n');
    itemp(indSF),SyRET(indSF),expos(indSF)

%Recalculates Vector of Ambient-Temperature Parameters:
    xEAmb = xEVal(17,:); syAmb = sy(17);
%Initializes Figures:
    fig.EiAF = figure('name','Retained Quasi-Elastic Modulus (Aluminum Foam)','units','inches','position',[1.5,1.75,5.5,3.75],'paperposition',[1.5,1.75,5.5,3.75]); ax = gca;
    fig.syAF = figure('name','Retained Yield Strength (Aluminum Foam)','units','inches','position',[1.5,1.75,5.5,3.75],'paperposition',[1.5,1.75,5.5,3.75]); ax = gca;
%Plots Elastic Data for Steel Foam:
    for ispec = indAF
        %Unpacks Data:
            %Load-Deformation Data:
                e = edata.(datafields{ispec}).e;
                s = edata.(datafields{ispec}).s;
            %Initial Elastic, Plastic Modulus, and Initial and Final
            %Densification Modulus: xCVal = [ki,ky,ry,ny,dbr,kb,kp,rb,nb,RConval,fvalC];
                EiRet = xEVal(ispec,1)/xEAmb(1);
                EiRET(ispec)=EiRet;
                syRet = sy(ispec)/syAmb;
                SyRET(ispec)=syRet;
        %Selects Relavent Markertype and Color:
            msizefact = 3.0;
            if expos(ispec) == 0
                mtype = 'd'; mcol = ax.ColorOrder(4,:); mfcol = 0.75*ax.ColorOrder(4,:); msize = 155/msizefact;
            elseif expos(ispec) == 15
                mtype = 'o'; mcol = ax.ColorOrder(1,:); mfcol = 0.75*ax.ColorOrder(1,:); msize = 160/msizefact;
            else
                mtype = 's'; mcol = ax.ColorOrder(2,:); mfcol = 0.75*ax.ColorOrder(2,:); msize = 250/msizefact;
            end
        %Defines Indices for Plot Handles According to Exposre:
            if expos(ispec)==15; iexpos = 2; elseif expos(ispec)==30; iexpos = 3; else; iexpos = 1; end
        %Plots Retained Quasi-Elastic Modulus:
            figure(fig.EiAF); ax = gca; %Selects Figure
%             hAF_Ei(iexpos) = scatter(itemp(ispec),EiRet,msize,mtype,'markeredgecolor',mcol,'markerfacecolor',mfcol,'markerfacealpha',0.50,'linewidth',1.0); hold all;
            hAF_Ei(iexpos) = scatter(itemp(ispec),EiRet,msize,mtype,'markeredgecolor','k','markerfacecolor','w','markerfacealpha',0.00,'linewidth',1.0); hold all;
            if ispec == indAF(end)
%                 ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [0.00,1.05];
%                 ax.FontSize = 11;
%                 xlabel('Temperature (°C)','fontsize',12);
%                 ylabel('Retained Quasi-Elastic Modulus','fontsize',12);
%                 hleg = legend(hAF_Ei,{sprintf('Ambient Temperature\n(No Exposure)'),'15 min Exposure','30 min Exposure'},'location','northeast');
%                 grid on; box on; drawnow;
%                 print(fig.EiAF,'EiAF','-dmeta');
                set(ax,'DefaultAxesColorOrder',[0,0,0]);
                set(ax,'DefaultAxesLineStyleOrder','-|s|o|x|v|>|p|d|:s|:o|:x|:v|:>|:p');
                set(ax, 'DefaultLineLineWidth',1.5);
                set(ax,'DefaultLineMarkerSize',5.0);
                ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [0.00,1.05];
                set(gca,'FontSize',12);
                hleg = legend(hAF_Ei,{sprintf('Ambient Temperature\n(No Exposure)'),'15 min Exposure','30 min Exposure'},'location','northeast');
                set(hleg,'FontSize',12,'box','on');   %set legend edges to white
                xlabel('Temperature (°C)','fontname','arial','fontsize',12);
                ylabel('Retained Quasi-Elastic Modulus','fontname','arial','fontsize',12);
                set(gca,'Box','on','TickDir','in','XGrid','off','YGrid','off','XColor',[.0 .0 .0],'YColor',[.0 .0 .0],'LineWidth',1);
                savefig(fig.EiAF,'TemplateFigs/Fig13b.fig')
                print(fig.EiAF,'TemplateFigs/Fig13b','-dmeta');
                print(fig.EiAF,'TemplateFigs/Fig13b','-deps2');
                print(fig.EiAF,'TemplateFigs/Fig13b','-dpdf');
            end
        %Plots Retained Yield Strength:
            figure(fig.syAF); ax = gca; %Selects Figure
%             hAF_sy(iexpos) = scatter(itemp(ispec),syRet,msize,mtype,'markeredgecolor',mcol,'markerfacecolor',mfcol,'markerfacealpha',0.50,'linewidth',1.0); hold all;
            hAF_sy(iexpos) = scatter(itemp(ispec),syRet,msize,mtype,'markeredgecolor','k','markerfacecolor','w','markerfacealpha',0.00,'linewidth',1.0); hold all;
            if ispec == indAF(end)
%                 ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [0.00,1.05];
%                 ax.FontSize = 11;
%                 xlabel('Temperature (°C)','fontsize',12);
%                 ylabel('Retained Yield Strength','fontsize',12);
%                 hleg = legend(hAF_sy,{sprintf('Ambient Temperature\n(No Exposure)'),'15 min Exposure','30 min Exposure'},'location','northeast');
%                 grid on; box on; drawnow;
%                 print(fig.syAF,'syAF','-dmeta');
                set(ax,'DefaultAxesColorOrder',[0,0,0]);
                set(ax,'DefaultAxesLineStyleOrder','-|s|o|x|v|>|p|d|:s|:o|:x|:v|:>|:p');
                set(ax, 'DefaultLineLineWidth',1.5);
                set(ax,'DefaultLineMarkerSize',5.0);
                ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [0.00,1.05];
                set(gca,'FontSize',12);
                hleg = legend(hAF_sy,{sprintf('Ambient Temperature\n(No Exposure)'),'15 min Exposure','30 min Exposure'},'location','northeast');
                set(hleg,'FontSize',12,'box','on');   %set legend edges to white
                xlabel('Temperature (°C)','fontname','arial','fontsize',12);
                ylabel('Retained Yield Strength','fontname','arial','fontsize',12);
                set(gca,'Box','on','TickDir','in','XGrid','off','YGrid','off','XColor',[.0 .0 .0],'YColor',[.0 .0 .0],'LineWidth',1);
                savefig(fig.syAF,'TemplateFigs/Fig9b.fig')
                print(fig.syAF,'TemplateFigs/Fig9b','-dmeta');
                print(fig.syAF,'TemplateFigs/Fig9b','-deps2');
                print(fig.syAF,'TemplateFigs/Fig9b','-dpdf');
            end
    end
    fprintf('Fig17(b):\n');
    itemp(indAF),EiRET(indAF),expos(indAF)
    fprintf('Fig13(b):\n');
    itemp(indAF),SyRET(indAF),expos(indAF)
    pause
    
%Initializes Matrix Plot:
    fig.matrixSF = figure('name','Elastic Matrix Plot (Steel Foam)','units','inches','position',1.25*[0.25,1.75,7.25,3.75],'paperposition',1.25*[0.25,1.75,7.25,3.75]); ax = gca;
    h = []; max_x = []; max_y = []; ifile = 1; nspec = length(indSF);
%Initializes Counter:
    ctr = 0;
%Defines Variable List (in order desired for constructing matrix plot)
    vlist = {'SF_T24C','SF_T150C_15','SF_T150C_30','SF_T200C_15','SF_T200C_30',...
             'SF_T300C_15','SF_T300C_15_cp9','SF_T300C_30','SF_T300C_30_cp10',...
             'SF_T400C_15_cp11','SF_T400C_30_cp12','SF_T550C_15','SF_T700C_15'};
    vlistlabel = {'SF_T24C','SF_T150C_15','SF_T150C_30','SF_T200C_15','SF_T200C_30',...
                  'SF_T300C_15(1)','SF_T300C_15(2)','SF_T300C_30(1)','SF_T300C_30(2)',...
                  'SF_T400C_15','SF_T400C_30','SF_T550C_15','SF_T700C_15'};
%Constructs Matrix Plots:
    for ispec = indSF
        %Increments Counter:
            ctr = ctr+1;
        %Determines Index within indSF:
            vind = find(ismember(datafields,vlist{ctr}));
        %Unpacks Load-Deformation Data:
            e = edata.(datafields{vind}).e;
            s = edata.(datafields{vind}).s;

        %Constructs Five-Paremeter Optimization to Stress-Strain Data:
            %Unpacks Optimized Parameters:
                xEEi = xEVal(vind,1); xEEy = xEVal(vind,2); xEry = xEVal(vind,3); xEny = xEVal(vind,4); xEeo = xEVal(vind,5);
            %Sends Elastic Parameters to Microsoft Excel File (so that they can be
            %formatted and copied into paper in Microsoft Word:
%                 xlswrite('TDRichardEquationFits.xlsx',cellstr(datafields{vind}),'ElasticFits',sprintf('A%d',ctr));
%                 xlswrite('TDRichardEquationFits.xlsx',xEVal(vind,1:5),'ElasticFits',sprintf('B%d:F%d',ctr,ctr));
            %Recalculates Fitted Response Curve:
                Ropt = (xEEi-xEEy)*(e-xEeo)./(1+abs(((xEEi-xEEy).*(e-xEeo))/xEry).^xEny).^(1/xEny) + xEEy*(e-xEeo);
                
        %Constructs Matrix Plot:
            %( [fig,h,max_x,max_y] = matplot(fig,h,spec,x1,y1,x2,y2,max_x,max_y,nspec,ifile,varargin) )
            [fig,h,max_x,max_y] = matplotElasticSF(fig,h,ctr,e,s,e,Ropt,max_x,max_y,nspec,ifile,vlistlabel);
        %Prints Figure:
            if ispec == indSF(end)
%                 print(fig.matrixSF,'matrixElasticSF','-dmeta');
                savefig(fig.matrixSF,'TemplateFigs/Fig12a.fig')
                print(fig.matrixSF,'TemplateFigs/Fig12a','-dmeta');
                print(fig.matrixSF,'TemplateFigs/Fig12a','-depsc2');
                print(fig.matrixSF,'TemplateFigs/Fig12a','-dpdf');
            end
        
    end
           
    
%Initializes Matrix Plot:
    fig = [];
    fig.matrixAF = figure('name','Elastic Matrix Plot (Steel Foam)','units','inches','position',0.95*[0.25,1.75,7.25,3.75],'paperposition',0.95*[0.25,1.75,7.25,3.75]); ax = gca;
    h = []; max_x = []; max_y = []; ifile = 1; nspec = length(indAF);
%Initializes Counter:
    ctr = 0;
%Defines Variable List (in order desired for constructing matrix plot)
    vlist = {'AF_T24C','AF_T150C_15','AF_T150C_30','AF_T200C_15','AF_T200C_30',...
             'AF_T300C_15','AF_T300C_30','AF_T500C_15'};
    vlistlabel = vlist;
%Constructs Matrix Plots:
    for ispec = indAF
        %Increments Counter:
            ctr = ctr+1;
        %Determines Index within indAF:
            vind = find(ismember(datafields,vlist{ctr}));
        %Unpacks Load-Deformation Data:
            e = edata.(datafields{vind}).e;
            s = edata.(datafields{vind}).s;

        %Constructs Five-Paremeter Optimization to Stress-Strain Data:
            %Unpacks Optimized Parameters:
                xEEi = xEVal(vind,1); xEEy = xEVal(vind,2); xEry = xEVal(vind,3); xEny = xEVal(vind,4); xEeo = xEVal(vind,5);
            %Sends Elastic Parameters to Microsoft Excel File (so that they can be
            %formatted and copied into paper in Microsoft Word:
%                 xlswrite('TDRichardEquationFits.xlsx',cellstr(datafields{vind}),'ElasticFits',sprintf('A%d',13+ctr));
%                 xlswrite('TDRichardEquationFits.xlsx',xEVal(vind,1:5),'ElasticFits',sprintf('B%d:F%d',13+ctr,13+ctr));
            %Recalculates Fitted Response Curve:
                Ropt = (xEEi-xEEy)*(e-xEeo)./(1+abs(((xEEi-xEEy).*(e-xEeo))/xEry).^xEny).^(1/xEny) + xEEy*(e-xEeo);
                
        %Constructs Matrix Plot:
            %( [fig,h,max_x,max_y] = matplot(fig,h,spec,x1,y1,x2,y2,max_x,max_y,nspec,ifile,varargin) )
            [fig,h,max_x,max_y] = matplotElasticAF(fig,h,ctr,e,s,e,Ropt,max_x,max_y,nspec,ifile,vlistlabel);
        %Prints Figure:
            if ispec == indAF(end)
%                 print(fig.matrixAF,'matrixElasticAF','-dmeta');
                savefig(fig.matrixAF,'TemplateFigs/Fig12b.fig')
                print(fig.matrixAF,'TemplateFigs/Fig12b','-dmeta');
                print(fig.matrixAF,'TemplateFigs/Fig12b','-depsc2');
                print(fig.matrixAF,'TemplateFigs/Fig12b','-dpdf');
            end
        %Aggregates Parameter Values:
            allParam(ctr,:) = [xEEi,xEEy,xEry,xEny];
    end
    allParam
    
    sprintf('%1.0f\n',allParam(:,1))
