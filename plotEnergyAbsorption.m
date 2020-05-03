function s_plateau = plotEnergyAbsorption(rawdata,xCVal)

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
    datafields = fieldnames(rawdata);    
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
    %Plateau Stress:
        %Initializes Plateau Stress:
            s_plateau = zeros(1,nspec);
        %Constructs Plateau Stress:
            for ispec = 1:nspec
                %Unpacks Stress and Strain Variables:
                    e = rawdata.(datafields{ispec}).e;
                    s = rawdata.(datafields{ispec}).s;
                %Locates Strains of 0.00 and 0.30:
                    energyInd = find(e<0.50);
                %Stores Data Applicable to Energy Absorption Calculation:
                    Endata.(datafields{ispec}).e = e(energyInd);
                    Endata.(datafields{ispec}).s = s(energyInd);
            end
            


%Recalculates Vector of Ambient-Temperature Parameters:
    energyAmb = trapz(Endata.SF_T24C.e,Endata.SF_T24C.s);
%Initializes Figures:
    fig.energySF = figure('name','Energy Absorption Capacity (Steel Foam)','units','inches','position',[1.5,1.75,5.5,3.75],'paperposition',[1.5,1.75,5.5,3.75]); ax = gca;
%Plots Elastic Data for Steel Foam:
    for ispec = indSF
        %Calculates Retained Plateau Stress;
            energyRet = trapz(Endata.(datafields{ispec}).e,Endata.(datafields{ispec}).s);
            ENRET(ispec)=energyRet;
%             energyRet = trapz(Endata.(datafields{ispec}).e,Endata.(datafields{ispec}).s)/energyAmb;
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
            figure(fig.energySF); ax = gca; %Selects Figure
%             hSF(iexpos) = scatter(itemp(ispec),energyRet,msize,mtype,'markeredgecolor',mcol,'markerfacecolor',mfcol,'markerfacealpha',0.50,'linewidth',1.0); hold all;
            hSF(iexpos) = scatter(itemp(ispec),energyRet,msize,mtype,'markeredgecolor','k','markerfacecolor','w','markerfacealpha',0.00,'linewidth',1.0); hold all;
            if ispec == indSF(end)
%                 ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [0.00,6.0];
%                 ax.FontSize = 11;
%                 xlabel('Temperature (°C)','fontsize',12);
%                 ylabel('Energy Absorption Capacity (MJ/m^3)','fontsize',12);
%                 hleg = legend(hSF,{sprintf('Ambient Temperature\n(No Exposure)'),'15 min Exposure','30 min Exposure'},'location','southwest');
%                 grid on; box on; drawnow;
%                 print(fig.energySF,'energySF','-dmeta');
                set(ax,'DefaultAxesColorOrder',[0,0,0]);
                set(ax,'DefaultAxesLineStyleOrder','-|s|o|x|v|>|p|d|:s|:o|:x|:v|:>|:p');
                set(ax, 'DefaultLineLineWidth',1.5);
                set(ax,'DefaultLineMarkerSize',5.0);
                ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [0.00,6.00];
                set(gca,'FontSize',12);
                hleg = legend(hSF,{sprintf('Ambient Temperature\n(No Exposure)'),'15 min Exposure','30 min Exposure'},'location','southwest');
                set(hleg,'FontSize',12,'box','on');   %set legend edges to white
                xlabel('Temperature (°C)','fontname','arial','fontsize',12);
                ylabel('Energy Absorption Capacity (MJ/m^3)','fontname','arial','fontsize',12);
                set(gca,'Box','on','TickDir','in','XGrid','off','YGrid','off','XColor',[.0 .0 .0],'YColor',[.0 .0 .0],'LineWidth',1);
                savefig(fig.energySF,'TemplateFigs/Fig11a.fig')
                print(fig.energySF,'TemplateFigs/Fig11a','-dmeta');
                print(fig.energySF,'TemplateFigs/Fig11a','-deps2');
                print(fig.energySF,'TemplateFigs/Fig11a','-dpdf');
            end
    end
    fprintf('Fig21(a):\n');
    itemp(indSF),ENRET(indSF),expos(indSF)
    
%Recalculates Vector of Ambient-Temperature Parameters:
    energyAmb = trapz(Endata.AF_T24C.e,Endata.AF_T24C.s);
%Initializes Figures:
    fig.energyAF = figure('name','Energy Absorption Capacity (Aluminum Foam)','units','inches','position',[1.5,1.75,5.5,3.75],'paperposition',[1.5,1.75,5.5,3.75]); ax = gca;
%Plots Elastic Data for Steel Foam:
    for ispec = indAF
        %Calculates Retained Plateau Stress;
            energyRet = trapz(Endata.(datafields{ispec}).e,Endata.(datafields{ispec}).s);
            ENRET(ispec)=energyRet;
%             energyRet = trapz(Endata.(datafields{ispec}).e,Endata.(datafields{ispec}).s)/energyAmb;
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
            figure(fig.energyAF); ax = gca; %Selects Figure
%             hAF(iexpos) = scatter(itemp(ispec),energyRet,msize,mtype,'markeredgecolor',mcol,'markerfacecolor',mfcol,'markerfacealpha',0.50,'linewidth',1.0); hold all;
            hAF(iexpos) = scatter(itemp(ispec),energyRet,msize,mtype,'markeredgecolor','k','markerfacecolor','w','markerfacealpha',0.00,'linewidth',1.0); hold all;
            if ispec == indAF(end)
%                 ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [0.00,15.0];
%                 ax.FontSize = 11;
%                 xlabel('Temperature (°C)','fontsize',12);
%                 ylabel('Energy Absorption Capacity (MJ/m^3)','fontsize',12);
%                 hleg = legend(hAF,{sprintf('Ambient Temperature\n(No Exposure)'),'15 min Exposure','30 min Exposure'},'location','northeast');
%                 grid on; box on; drawnow;
%                 print(fig.energyAF,'energyAF','-dmeta');
                set(ax,'DefaultAxesColorOrder',[0,0,0]);
                set(ax,'DefaultAxesLineStyleOrder','-|s|o|x|v|>|p|d|:s|:o|:x|:v|:>|:p');
                set(ax, 'DefaultLineLineWidth',1.5);
                set(ax,'DefaultLineMarkerSize',5.0);
                ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [0.00,15.00];
                set(gca,'FontSize',12);
                hleg = legend(hAF,{sprintf('Ambient Temperature\n(No Exposure)'),'15 min Exposure','30 min Exposure'},'location','northeast');
                set(hleg,'FontSize',12,'box','on');   %set legend edges to white
                xlabel('Temperature (°C)','fontname','arial','fontsize',12);
                ylabel('Energy Absorption Capacity (MJ/m^3)','fontname','arial','fontsize',12);
                set(gca,'Box','on','TickDir','in','XGrid','off','YGrid','off','XColor',[.0 .0 .0],'YColor',[.0 .0 .0],'LineWidth',1);
                savefig(fig.energyAF,'TemplateFigs/Fig11a.fig')
                print(fig.energyAF,'TemplateFigs/Fig11b','-dmeta');
                print(fig.energyAF,'TemplateFigs/Fig11b','-deps2');
                print(fig.energyAF,'TemplateFigs/Fig11b','-dpdf');
            end
    end
    fprintf('Fig21(b):\n');
    itemp(indAF),ENRET(indAF),expos(indAF)
    

    
%Initializes Figures:
    fig.energyEfficiencySF = figure('name','Energy Absorption Efficiency (Steel Foam)','units','inches','position',[1.5,1.75,5.5,3.75],'paperposition',[1.5,1.75,5.5,3.75]); ax = gca;
%Plots Elastic Data for Steel Foam:
    for ispec = indSF
        %Unpacks Stress and Strain Variables:
            e = rawdata.(datafields{ispec}).e;
            s = rawdata.(datafields{ispec}).s;
        %Calculates Retained Plateau Stress;
            energyEfficiency = trapz(e(e<=xCVal(ispec,5)),s(e<=xCVal(ispec,5)))/(xCVal(ispec,5)*xCVal(ispec,10));
            ENEFFIC(ispec)=energyEfficiency;
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
            figure(fig.energyEfficiencySF); ax = gca; %Selects Figure
%             hSF(iexpos) = scatter(itemp(ispec),energyEfficiency,msize,mtype,'markeredgecolor',mcol,'markerfacecolor',mfcol,'markerfacealpha',0.50,'linewidth',1.0); hold all;
            hSF(iexpos) = scatter(itemp(ispec),energyEfficiency,msize,mtype,'markeredgecolor','k','markerfacecolor','w','markerfacealpha',0.00,'linewidth',1.0); hold all;
            if ispec == indSF(end)
%                 ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [0.00,1.00];
%                 ax.FontSize = 11;
%                 xlabel('Temperature (°C)','fontsize',12);
%                 ylabel('Energy Absorption Efficiency (%)','fontsize',12);
%                 hleg = legend(hSF,{sprintf('Ambient Temperature\n(No Exposure)'),'15 min Exposure','30 min Exposure'},'location','southwest');
%                 grid on; box on; drawnow;
%                 print(fig.energyEfficiencySF,'energyEfficiencySF','-dmeta');
                set(ax,'DefaultAxesColorOrder',[0,0,0]);
                set(ax,'DefaultAxesLineStyleOrder','-|s|o|x|v|>|p|d|:s|:o|:x|:v|:>|:p');
                set(ax, 'DefaultLineLineWidth',1.5);
                set(ax,'DefaultLineMarkerSize',5.0);
                ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [0.00,1.00];
                set(gca,'FontSize',12);
                hleg = legend(hSF,{sprintf('Ambient Temperature\n(No Exposure)'),'15 min Exposure','30 min Exposure'},'location','southwest');
                set(hleg,'FontSize',12,'box','on');   %set legend edges to white
                xlabel('Temperature (°C)','fontname','arial','fontsize',12);
                ylabel('Energy Absorption Efficiency (%)','fontname','arial','fontsize',12);
                set(gca,'Box','on','TickDir','in','XGrid','off','YGrid','off','XColor',[.0 .0 .0],'YColor',[.0 .0 .0],'LineWidth',1);
                savefig(fig.energyEfficiencySF,'TemplateFigs/Fig18a.fig')
                print(fig.energyEfficiencySF,'TemplateFigs/Fig18a','-dmeta');
                print(fig.energyEfficiencySF,'TemplateFigs/Fig18a','-deps2');
                print(fig.energyEfficiencySF,'TemplateFigs/Fig18a','-dpdf');
            end
    end    
	fprintf('Fig22(a):\n');
    itemp(indSF),ENEFFIC(indSF),expos(indSF)
    
%Initializes Figures:
    fig.energyEfficiencyAF = figure('name','Energy Absorption Efficiency (Aluminum Foam)','units','inches','position',[1.5,1.75,5.5,3.75],'paperposition',[1.5,1.75,5.5,3.75]); ax = gca;
%Plots Elastic Data for Steel Foam:
    for ispec = indAF
        %Calculates Retained Plateau Stress;
            energyEfficiency = trapz(e(e<=xCVal(ispec,5)),s(e<=xCVal(ispec,5)))/(xCVal(ispec,5)*xCVal(ispec,10));
            ENEFFIC(ispec)=energyEfficiency;
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
            figure(fig.energyEfficiencyAF); ax = gca; %Selects Figure
%             hAF(iexpos) = scatter(itemp(ispec),energyEfficiency,msize,mtype,'markeredgecolor',mcol,'markerfacecolor',mfcol,'markerfacealpha',0.50,'linewidth',1.0); hold all;
            hAF(iexpos) = scatter(itemp(ispec),energyEfficiency,msize,mtype,'markeredgecolor','k','markerfacecolor','w','markerfacealpha',0.00,'linewidth',1.0); hold all;
            if ispec == indAF(end)
%                 ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [0.00,1.00];
%                 ax.FontSize = 11;
%                 xlabel('Temperature (°C)','fontsize',12);
%                 ylabel('Energy Absorption Efficiency (%)','fontsize',12);
%                 hleg = legend(hAF,{sprintf('Ambient Temperature\n(No Exposure)'),'15 min Exposure','30 min Exposure'},'location','southeast');
%                 grid on; box on; drawnow;
%                 print(fig.energyEfficiencyAF,'energyEfficiencyAF','-dmeta');
                set(ax,'DefaultAxesColorOrder',[0,0,0]);
                set(ax,'DefaultAxesLineStyleOrder','-|s|o|x|v|>|p|d|:s|:o|:x|:v|:>|:p');
                set(ax, 'DefaultLineLineWidth',1.5);
                set(ax,'DefaultLineMarkerSize',5.0);
                ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [0.00,1.00];
                set(gca,'FontSize',12);
                hleg = legend(hAF,{sprintf('Ambient Temperature\n(No Exposure)'),'15 min Exposure','30 min Exposure'},'location','southeast');
                set(hleg,'FontSize',12,'box','on');   %set legend edges to white
                xlabel('Temperature (°C)','fontname','arial','fontsize',12);
                ylabel('Energy Absorption Efficiency (%)','fontname','arial','fontsize',12);
                set(gca,'Box','on','TickDir','in','XGrid','off','YGrid','off','XColor',[.0 .0 .0],'YColor',[.0 .0 .0],'LineWidth',1);
                savefig(fig.energyEfficiencyAF,'TemplateFigs/Fig18b.fig')
                print(fig.energyEfficiencyAF,'TemplateFigs/Fig18b','-dmeta');
                print(fig.energyEfficiencyAF,'TemplateFigs/Fig18b','-deps2');
                print(fig.energyEfficiencyAF,'TemplateFigs/Fig18b','-dpdf');
            end
    end
    fprintf('Fig22(b):\n');
    itemp(indAF),ENEFFIC(indAF),expos(indAF)
    pause
    
    
    