function s_plateau = plotProcessedData(rawdata,xCVal)

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
                %Locates Stress between Strains of 0.20 and 0.30:
                    s_plateau(ispec) = mean(s(e > 0.20 & e < 0.30));
            end
            


%Defines List of Applicable Steel Foam Temperatures:
    tlist = unique(itemp);
    indDestroy = 6;
    tlist(indDestroy) = [];
%Plots Stress-Strain Response of Steel Foam Specimens:
    fig.seSF = figure('name','Stress-Strain Response of Steel Foam','units','inches','position',[7.5,1.75,5.5,3.75],'paperposition',[7.5,1.75,5.5,3.75]); ax = gca;
    figure(fig.seSF)
%Plots Steel Foam Data:
    for ispec = indSF
        %Unpacks Stress and Strain Variables:
            e = rawdata.(datafields{ispec}).e;  %Engineering Strain Data
            s = rawdata.(datafields{ispec}).s;  %Engineering Stress Data
            ctemp = itemp(ispec);               %Current Temperature
            cind = find(tlist==ctemp);  %Ordered List of All Temperatures
        %Plots Engineering Stress-Strain Response:
            %Defines Line Color:
                if cind <= 7; pcol = ax.ColorOrder(cind,:); else pcol = [0,0,0]; end
            %Plots Data:
                h(cind) = plot(e,s,'-','color',pcol,'linewidth',1.75); hold all; %#ok<AGROW>
            %Defines Legend:
                if ispec == indSF(end)
                    hleg = legend(h,{'24 °C','150 °C','200 °C','300 °C','400 °C','550 °C','700 °C'},'location','northwest');
                end
            %Plot Properties:
                if ispec == indSF(end)
                    ax.FontSize = 12;
                    ax.XLim = [0,0.765]; ax.YLim = [0,48.0];
                    hleg.Position = hleg.Position + [-0.005,0.01,0,0];
                    xlabel('Engineering Strain (mm/mm)','fontsize',14);
                    ylabel('Engineering Stress (MPa)','fontsize',14);
                    grid on; box on; drawnow;
                    print(fig.seSF,'seSF','-dmeta');
                end
    end

%Defines List of Applicable Aluminum Foam Temperatures:
    tlist = unique(itemp);
    indDestroy = [5,7,8];
    tlist(indDestroy) = [];
%Plots Stress-Strain Response of Aluminum Foam Specimens:
    fig.seAF = figure('name','Stress-Strain Response of Aluminum Foam','units','inches','position',[1.5,1.75,5.5,3.75],'paperposition',[1.5,1.75,5.5,3.75]); ax = gca;
    figure(fig.seAF)
%Plots Steel Foam Data:
    for ispec = indAF
        %Unpacks Stress and Strain Variables:
            e = rawdata.(datafields{ispec}).e;  %Engineering Strain Data
            s = rawdata.(datafields{ispec}).s;  %Engineering Stress Data
            ctemp = itemp(ispec);               %Current Temperature
            cind = find(tlist==ctemp);  %Ordered List of All Temperatures
        %Plots Engineering Stress-Strain Response:
            %Defines Line Color:
                if cind <= 7; pcol = ax.ColorOrder(cind,:); else pcol = [0,0,0]; end
            %Plots Data:
                hAF(cind) = plot(e,s,'-','color',pcol,'linewidth',1.75); hold all; %#ok<AGROW>
            %Defines Legend:
                if ispec == indAF(end)
                    hleg = legend(hAF,{'24 °C','150 °C','200 °C','300 °C','500 °C'},'location','northwest');
                end
            %Plot Properties:
                if ispec == indAF(end)
                    ax.FontSize = 12;
                    ax.XLim = [0,0.765]; ax.YLim = [0,48.0];
                    hleg.Position = hleg.Position + [-0.005,0.01,0,0];
                    xlabel('Engineering Strain (mm/mm)','fontsize',14);
                    ylabel('Engineering Stress (MPa)','fontsize',14);
                    grid on; box on; drawnow;
                    print(fig.seAF,'seAF','-dmeta');
                end
    end

    
%Recalculates Vector of Ambient-Temperature Parameters:
    s_plateauAmb = s_plateau(4);
%Initializes Figures:
    fig.s_plateauSF = figure('name','Retained Plateau Stress (Steel Foam)','units','inches','position',[1.5,1.75,5.5,3.75],'paperposition',[1.5,1.75,5.5,3.75]); ax = gca;
%Plots Elastic Data for Steel Foam:
    for ispec = indSF
        %Calculates Retained Plateau Stress;
            s_retainedRet = s_plateau(ispec)/s_plateauAmb;
            SRET(ispec)=s_retainedRet;
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
            figure(fig.s_plateauSF); ax = gca; %Selects Figure
%             hSF(iexpos) = scatter(itemp(ispec),s_retainedRet,msize,mtype,'markeredgecolor',mcol,'markerfacecolor',mfcol,'markerfacealpha',0.50,'linewidth',1.0); hold all;
            hSF(iexpos) = scatter(itemp(ispec),s_retainedRet,msize,mtype,'markeredgecolor','k','markerfacecolor','w','markerfacealpha',0.00,'linewidth',1.0); hold all;
            if ispec == indSF(end)
                set(ax,'DefaultAxesColorOrder',[0,0,0]);
                set(ax,'DefaultAxesLineStyleOrder','-|s|o|x|v|>|p|d|:s|:o|:x|:v|:>|:p');
                set(ax, 'DefaultLineLineWidth',1.5);
                set(ax,'DefaultLineMarkerSize',5.0);
                ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [0.00,1.05];
                set(gca,'FontSize',12);
                hleg = legend(hSF,{sprintf('Ambient Temperature\n(No Exposure)'),'15 min Exposure','30 min Exposure'},'location','southwest');
                set(hleg,'FontSize',12,'box','on');   %set legend edges to white
                xlabel('Temperature (°C)','fontname','arial','fontsize',12);
                ylabel('Retained Plateau Stress','fontname','arial','fontsize',12);
                set(gca,'Box','on','TickDir','in','XGrid','off','YGrid','off','XColor',[.0 .0 .0],'YColor',[.0 .0 .0],'LineWidth',1);
                savefig(fig.s_plateauSF,'TemplateFigs/Fig10a.fig')
                print(fig.s_plateauSF,'TemplateFigs/Fig10a','-dmeta');
                print(fig.s_plateauSF,'TemplateFigs/Fig10a','-deps2');
                print(fig.s_plateauSF,'TemplateFigs/Fig10a','-dpdf');
            end
    end
    fprintf('Fig14(a):\n');
    itemp(indSF),SRET(indSF),expos(indSF)
    
    SRET = [];
%Recalculates Vector of Ambient-Temperature Parameters:
    s_plateauAmb = s_plateau(17);
%Initializes Figures:
    fig.s_plateauAF = figure('name','Retained Plateau Stress (Aluminum Foam)','units','inches','position',[1.5,1.75,5.5,3.75],'paperposition',[1.5,1.75,5.5,3.75]); ax = gca;
%Plots Elastic Data for Steel Foam:
    for ispec = indAF
        %Calculates Retained Plateau Stress;
            s_retainedRet = s_plateau(ispec)/s_plateauAmb;
            SRET(ispec)=s_retainedRet;
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
            figure(fig.s_plateauAF); ax = gca; %Selects Figure
%             hAF(iexpos) = scatter(itemp(ispec),s_retainedRet,msize,mtype,'markeredgecolor',mcol,'markerfacecolor',mfcol,'markerfacealpha',0.50,'linewidth',1.0); hold all;
            hAF(iexpos) = scatter(itemp(ispec),s_retainedRet,msize,mtype,'markeredgecolor','k','markerfacecolor','w','markerfacealpha',0.00,'linewidth',1.0); hold all;
            if ispec == indAF(end)
                set(ax,'DefaultAxesColorOrder',[0,0,0]);
                set(ax,'DefaultAxesLineStyleOrder','-|s|o|x|v|>|p|d|:s|:o|:x|:v|:>|:p');
                set(ax, 'DefaultLineLineWidth',1.5);
                set(ax,'DefaultLineMarkerSize',5.0);
                ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [0.00,1.05];
                set(gca,'FontSize',12);
                hleg = legend(hAF,{sprintf('Ambient Temperature\n(No Exposure)'),'15 min Exposure','30 min Exposure'},'location','northeast');
                set(hleg,'FontSize',12,'box','on');   %set legend edges to white
                xlabel('Temperature (°C)','fontname','arial','fontsize',12);
                ylabel('Retained Plateau Stress','fontname','arial','fontsize',12);
                set(gca,'Box','on','TickDir','in','XGrid','off','YGrid','off','XColor',[.0 .0 .0],'YColor',[.0 .0 .0],'LineWidth',1);
                savefig(fig.s_plateauAF,'TemplateFigs/Fig10b.fig')
                print(fig.s_plateauAF,'TemplateFigs/Fig10b','-dmeta');
                print(fig.s_plateauAF,'TemplateFigs/Fig10b','-deps2');
                print(fig.s_plateauAF,'TemplateFigs/Fig10b','-dpdf');
            end
    end
    fprintf('Fig14(b):\n');
    itemp(indAF),SRET(indAF),expos(indAF)
    
    
%Densification Strain:
%Recalculates Vector of Ambient-Temperature Parameters:
    e_densificationAmb = xCVal(4,5);
%Initializes Figures:
    fig.e_densificationSF = figure('name','Densification Strain (Steel Foam)','units','inches','position',[1.5,1.75,5.5,3.75],'paperposition',[1.5,1.75,5.5,3.75]); ax = gca;
%Plots Elastic Data for Steel Foam:
    for ispec = indSF
        %Calculates Retained Plateau Stress;
%             e_densificationRet = xCVal(ispec,5)/e_densificationAmb;
            e_densificationRet = xCVal(ispec,5);
            e_densificationRET(ispec)=e_densificationRet;
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
            figure(fig.e_densificationSF); ax = gca; %Selects Figure
%             hSF(iexpos) = scatter(itemp(ispec),e_densificationRet,msize,mtype,'markeredgecolor',mcol,'markerfacecolor',mfcol,'markerfacealpha',0.50,'linewidth',1.0); hold all;
            hSF(iexpos) = scatter(itemp(ispec),e_densificationRet,msize,mtype,'markeredgecolor','k','markerfacecolor','w','markerfacealpha',0.00,'linewidth',1.0); hold all;
            if ispec == indSF(end)
%                 ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [0.00,0.50];
%                 ax.FontSize = 11;
%                 xlabel('Temperature (°C)','fontsize',12);
%                 ylabel('Densification Strain (mm/mm)','fontsize',12);
%                 hleg = legend(hSF,{sprintf('Ambient Temperature\n(No Exposure)'),'15 min Exposure','30 min Exposure'},'location','southwest');
%                 grid on; box on; drawnow;
%                 print(fig.e_densificationSF,'edensificationSF','-dmeta');
                set(ax,'DefaultAxesColorOrder',[0,0,0]);
                set(ax,'DefaultAxesLineStyleOrder','-|s|o|x|v|>|p|d|:s|:o|:x|:v|:>|:p');
                set(ax, 'DefaultLineLineWidth',1.5);
                set(ax,'DefaultLineMarkerSize',5.0);
                ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [0.00,0.50];
                set(gca,'FontSize',12);
                hleg = legend(hSF,{sprintf('Ambient Temperature\n(No Exposure)'),'15 min Exposure','30 min Exposure'},'location','southwest');
                set(hleg,'FontSize',12,'box','on');   %set legend edges to white
                xlabel('Temperature (°C)','fontname','arial','fontsize',12);
                ylabel('Densification Strain (mm/mm)','fontname','arial','fontsize',12);
                set(gca,'Box','on','TickDir','in','XGrid','off','YGrid','off','XColor',[.0 .0 .0],'YColor',[.0 .0 .0],'LineWidth',1);
                savefig(fig.e_densificationSF,'TemplateFigs/Fig16a.fig')
                print(fig.e_densificationSF,'TemplateFigs/Fig16a','-dmeta');
                print(fig.e_densificationSF,'TemplateFigs/Fig16a','-deps2');
                print(fig.e_densificationSF,'TemplateFigs/Fig16a','-dpdf');
            end
    end    
    fprintf('Fig19(a):\n');
    itemp(indAF),e_densificationRET(indSF),expos(indSF)
    
%Recalculates Vector of Ambient-Temperature Parameters:
    e_densificationAmb = xCVal(17,5);
%Initializes Figures:
    fig.e_densificationAF = figure('name','Densification Strain (Aluminum Foam)','units','inches','position',[1.5,1.75,5.5,3.75],'paperposition',[1.5,1.75,5.5,3.75]); ax = gca;
%Plots Elastic Data for Steel Foam:
    for ispec = indAF
        %Calculates Retained Plateau Stress;
%             e_densificationRet = xCVal(ispec,5)/e_densificationAmb;
            e_densificationRet = xCVal(ispec,5);
            e_densificationRET(ispec)=e_densificationRet;
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
            figure(fig.e_densificationAF); ax = gca; %Selects Figure
%             hAF(iexpos) = scatter(itemp(ispec),e_densificationRet,msize,mtype,'markeredgecolor',mcol,'markerfacecolor',mfcol,'markerfacealpha',0.50,'linewidth',1.0); hold all;
            hAF(iexpos) = scatter(itemp(ispec),e_densificationRet,msize,mtype,'markeredgecolor','k','markerfacecolor','w','markerfacealpha',0.00,'linewidth',1.0); hold all;
            if ispec == indAF(end)
%                 ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [0.00,0.50];
%                 ax.FontSize = 11;
%                 xlabel('Temperature (°C)','fontsize',12);
%                 ylabel('Densification Strain (mm/mm)','fontsize',12);
%                 hleg = legend(hAF,{sprintf('Ambient Temperature\n(No Exposure)'),'15 min Exposure','30 min Exposure'},'location','southwest');
%                 grid on; box on; drawnow;
%                 print(fig.e_densificationAF,'edensificationAF','-dmeta');
                set(ax,'DefaultAxesColorOrder',[0,0,0]);
                set(ax,'DefaultAxesLineStyleOrder','-|s|o|x|v|>|p|d|:s|:o|:x|:v|:>|:p');
                set(ax, 'DefaultLineLineWidth',1.5);
                set(ax,'DefaultLineMarkerSize',5.0);
                ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [0.00,0.50];
                set(gca,'FontSize',12);
                hleg = legend(hAF,{sprintf('Ambient Temperature\n(No Exposure)'),'15 min Exposure','30 min Exposure'},'location','southwest');
                set(hleg,'FontSize',12,'box','on');   %set legend edges to white
                xlabel('Temperature (°C)','fontname','arial','fontsize',12);
                ylabel('Densification Strain (mm/mm)','fontname','arial','fontsize',12);
                set(gca,'Box','on','TickDir','in','XGrid','off','YGrid','off','XColor',[.0 .0 .0],'YColor',[.0 .0 .0],'LineWidth',1);
                savefig(fig.e_densificationAF,'TemplateFigs/Fig16b.fig')
                print(fig.e_densificationAF,'TemplateFigs/Fig16b','-dmeta');
                print(fig.e_densificationAF,'TemplateFigs/Fig16b','-deps2');
                print(fig.e_densificationAF,'TemplateFigs/Fig16b','-dpdf');
            end
    end
    fprintf('Fig19(b):\n');
    itemp(indAF),e_densificationRET(indAF),expos(indAF)
    pause
    
%Stores Vector of Ambient-Temperature Parameters:
    EpAmb = xCVal(4,2);
%Initializes Figures:
    fig.EpSF = figure('name','Quasi-Hardening Modulus (Steel Foam)','units','inches','position',[1.5,1.75,5.5,3.75],'paperposition',[1.5,1.75,5.5,3.75]); ax = gca;
%Plots Calculated Parameters for Steel Foam Data:
    for ispec = indSF
        %Unpacks Data:
            %Plastic Modulus, and Initial and Final Densification Modulus:
            %( xCVal = [ki,ky,ry,ny,dbr,kb,kp,rb,nb,RConval,fvalC] );
                Ep = xCVal(ispec,2); 
                EP(ispec)=Ep;
%                 Ep = xCVal(ispec,2)/EpAmb;
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
        %Plots Quasi-Plastic Hardening Modulus:
            figure(fig.EpSF); ax = gca; %Selects Figure
%             hSF(iexpos) = scatter(itemp(ispec),Ep,msize,mtype,'markeredgecolor',mcol,'markerfacecolor',mfcol,'markerfacealpha',0.50,'linewidth',1.0); hold all;
            hSF(iexpos) = scatter(itemp(ispec),Ep,msize,mtype,'markeredgecolor','k','markerfacecolor','w','markerfacealpha',0.00,'linewidth',1.0); hold all;
            if ispec == indSF(end)
%                 ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [0,21.5];
%                 ax.FontSize = 11;
%                 xlabel('Temperature (°C)','fontsize',12);
%                 ylabel('Quasi-Hardening Modulus (MPa)','fontsize',12);
%                 hleg = legend(hSF,{sprintf('Ambient Temperature\n(No Exposure)'),'15 min Exposure','30 min Exposure'},'location','northwest');
%                 grid on; box on; drawnow;
%                 print(fig.EpSF,'EpSF','-dmeta');
                set(ax,'DefaultAxesColorOrder',[0,0,0]);
                set(ax,'DefaultAxesLineStyleOrder','-|s|o|x|v|>|p|d|:s|:o|:x|:v|:>|:p');
                set(ax, 'DefaultLineLineWidth',1.5);
                set(ax,'DefaultLineMarkerSize',5.0);
                ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [0.00,21.5];
                set(gca,'FontSize',12);
                hleg = legend(hSF,{sprintf('Ambient Temperature\n(No Exposure)'),'15 min Exposure','30 min Exposure'},'location','northwest');
                set(hleg,'FontSize',12,'box','on');   %set legend edges to white
                xlabel('Temperature (°C)','fontname','arial','fontsize',12);
                ylabel('Quasi-Hardening Modulus (MPa)','fontname','arial','fontsize',12);
                set(gca,'Box','on','TickDir','in','XGrid','off','YGrid','off','XColor',[.0 .0 .0],'YColor',[.0 .0 .0],'LineWidth',1);
                savefig(fig.EpSF,'TemplateFigs/Fig15a.fig')
                print(fig.EpSF,'TemplateFigs/Fig15a','-dmeta');
                print(fig.EpSF,'TemplateFigs/Fig15a','-deps2');
                print(fig.EpSF,'TemplateFigs/Fig15a','-dpdf');
            end
    end
    fprintf('Fig18(a):\n');
    itemp(indSF),EP(indSF),expos(indSF)
    
%Stores Vector of Ambient-Temperature Parameters:
    EpAmb = xCVal(17,2);
%Initializes Figures:
    fig.EpAF = figure('name','Quasi-Hardening Modulus (Aluminum Foam)','units','inches','position',[1.5,1.75,5.5,3.75],'paperposition',[1.5,1.75,5.5,3.75]); ax = gca;
%Plots Calculated Parameters for Steel Foam Data:
    for ispec = indAF
        %Unpacks Data:
            %Plastic Modulus, and Initial and Final Densification Modulus:
            %( xCVal = [ki,ky,ry,ny,dbr,kb,kp,rb,nb,RConval,fvalC] );
                Ep = xCVal(ispec,2);
                EP(ispec)=Ep;
%                 Ep = xCVal(ispec,2)/xCAmb(2);
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
        %Plots Quasi-Plastic Hardening Modulus:
            figure(fig.EpAF); ax = gca; %Selects Figure
%             hAF(iexpos) = scatter(itemp(ispec),Ep,msize,mtype,'markeredgecolor',mcol,'markerfacecolor',mfcol,'markerfacealpha',0.50,'linewidth',1.0); hold all;
            hAF(iexpos) = scatter(itemp(ispec),Ep,msize,mtype,'markeredgecolor','k','markerfacecolor','w','markerfacealpha',0.00,'linewidth',1.0); hold all;
            if ispec == indAF(end)
%                 ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [0,21.5];
%                 ax.FontSize = 11;
%                 xlabel('Temperature (°C)','fontsize',12);
%                 ylabel('Quasi-Hardening Modulus (MPa)','fontsize',12);
%                 hleg = legend(hAF,{sprintf('Ambient Temperature\n(No Exposure)'),'15 min Exposure','30 min Exposure'},'location','northeast');
%                 grid on; box on; drawnow;
%                 print(fig.EpAF,'EpAF','-dmeta');
                set(ax,'DefaultAxesColorOrder',[0,0,0]);
                set(ax,'DefaultAxesLineStyleOrder','-|s|o|x|v|>|p|d|:s|:o|:x|:v|:>|:p');
                set(ax, 'DefaultLineLineWidth',1.5);
                set(ax,'DefaultLineMarkerSize',5.0);
                ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [0.00,21.5];
                set(gca,'FontSize',12);
                hleg = legend(hAF,{sprintf('Ambient Temperature\n(No Exposure)'),'15 min Exposure','30 min Exposure'},'location','northeast');
                set(hleg,'FontSize',12,'box','on');   %set legend edges to white
                xlabel('Temperature (°C)','fontname','arial','fontsize',12);
                ylabel('Quasi-Hardening Modulus (MPa)','fontname','arial','fontsize',12);
                set(gca,'Box','on','TickDir','in','XGrid','off','YGrid','off','XColor',[.0 .0 .0],'YColor',[.0 .0 .0],'LineWidth',1);
                savefig(fig.EpAF,'TemplateFigs/Fig15b.fig')
                print(fig.EpAF,'TemplateFigs/Fig15b','-dmeta');
                print(fig.EpAF,'TemplateFigs/Fig15b','-deps2');
                print(fig.EpAF,'TemplateFigs/Fig15b','-dpdf');
            end
    end
    fprintf('Fig18(b):\n');
    itemp(indAF),EP(indAF),expos(indAF)

%Initializes Matrix Plot:
    fig.matrixSF = figure('name','Elastic Matrix Plot (Steel Foam)','units','inches','position',1.25*[0.25,1.75,7.00,4.25],...
        'paperposition',1.25*[0.25,1.75,7.00,4.25]); ax = gca;
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
            e = rawdata.(datafields{vind}).e;
            s = rawdata.(datafields{vind}).s;

        %Constructs Nine-Paremeter Optimization to Stress-Strain Data:
            %Unpacks Optimized Parameters:
                xCki = xCVal(vind,1); xCky = xCVal(vind,2); xCry = xCVal(vind,3); xCny = xCVal(vind,4); xCdbr = xCVal(vind,5); 
                xCkb = xCVal(vind,6); xCkp = xCVal(vind,7); xCrb = xCVal(vind,8); xCnb = xCVal(vind,9);
            %Sends Elastic Parameters to Microsoft Excel File (so that they can be
            %formatted and copied into paper in Microsoft Word:
%                 xlswrite('TDRichardEquationFits.xlsx',cellstr(datafields{vind}),'PlasticFits',sprintf('A%d',ctr));
%                 xlswrite('TDRichardEquationFits.xlsx',xCVal(vind,1:9),'PlasticFits',sprintf('B%d:J%d',ctr,ctr));
            %Recalculates Fitted Response Curve:
                RCon = zeros(size(e));
                RCon(e<=xCdbr) = (xCki-xCky)*e(e<=xCdbr)./(1+abs(((xCki-xCky).*e(e<=xCdbr))/xCry).^xCny).^(1/xCny) + xCky*e(e<=xCdbr);
                RConval = (xCki-xCky)*xCdbr./(1+abs(((xCki-xCky).*xCdbr)/xCry).^xCny).^(1/xCny) + xCky*xCdbr;
                RCon(e>xCdbr) = RConval + (xCkb-xCkp)*(e(e>xCdbr)-xCdbr)./(1+abs(((xCkb-xCkp).*(e(e>xCdbr)-xCdbr))/xCrb).^xCnb).^(1/xCnb) + xCkp*(e(e>xCdbr)-xCdbr);

        %Constructs Matrix Plot:
            %( [fig,h,max_x,max_y] = matplot(fig,h,spec,x1,y1,x2,y2,max_x,max_y,nspec,ifile,varargin) )
            [fig,h,max_x,max_y] = matplotSF(fig,h,ctr,e,s,e,RCon,max_x,max_y,nspec,ifile,vlistlabel);
        %Prints Figure:
            if ispec == indSF(end)
%                 print(fig.matrixSF,'matrixSF','-dmeta');
                savefig(fig.matrixSF,'TemplateFigs/Fig14a.fig')
                print(fig.matrixSF,'TemplateFigs/Fig14a','-dmeta');
                print(fig.matrixSF,'TemplateFigs/Fig14a','-depsc2');
                print(fig.matrixSF,'TemplateFigs/Fig14a','-dpdf');
            end
        
    end
           
    
%Initializes Matrix Plot:
    fig = [];
    fig.matrixAF = figure('name','Elastic Matrix Plot (Steel Foam)','units','inches','position',0.95*[0.25,1.75,7.00,4.25],...
        'paperposition',0.95*[0.25,1.75,7.00,4.25]); ax = gca;
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
            e = rawdata.(datafields{vind}).e;
            s = rawdata.(datafields{vind}).s;

        %Constructs Nine-Paremeter Optimization to Stress-Strain Data:
            %Unpacks Optimized Parameters:
                xCki = xCVal(vind,1); xCky = xCVal(vind,2); xCry = xCVal(vind,3); xCny = xCVal(vind,4); xCdbr = xCVal(vind,5); 
                xCkb = xCVal(vind,6); xCkp = xCVal(vind,7); xCrb = xCVal(vind,8); xCnb = xCVal(vind,9);
            %Sends Elastic Parameters to Microsoft Excel File (so that they can be
            %formatted and copied into paper in Microsoft Word:
%                 xlswrite('TDRichardEquationFits.xlsx',cellstr(datafields{vind}),'PlasticFits',sprintf('A%d',13+ctr));
%                 xlswrite('TDRichardEquationFits.xlsx',xCVal(vind,1:9),'PlasticFits',sprintf('B%d:J%d',13+ctr,13+ctr));
            %Recalculates Fitted Response Curve:
                RCon = zeros(size(e));
                RCon(e<=xCdbr) = (xCki-xCky)*e(e<=xCdbr)./(1+abs(((xCki-xCky).*e(e<=xCdbr))/xCry).^xCny).^(1/xCny) + xCky*e(e<=xCdbr);
                RConval = (xCki-xCky)*xCdbr./(1+abs(((xCki-xCky).*xCdbr)/xCry).^xCny).^(1/xCny) + xCky*xCdbr;
                RCon(e>xCdbr) = RConval + (xCkb-xCkp)*(e(e>xCdbr)-xCdbr)./(1+abs(((xCkb-xCkp).*(e(e>xCdbr)-xCdbr))/xCrb).^xCnb).^(1/xCnb) + xCkp*(e(e>xCdbr)-xCdbr);
                
        %Constructs Matrix Plot:
            %( [fig,h,max_x,max_y] = matplot(fig,h,spec,x1,y1,x2,y2,max_x,max_y,nspec,ifile,varargin) )
            [fig,h,max_x,max_y] = matplotAF(fig,h,ctr,e,s,e,RCon,max_x,max_y,nspec,ifile,vlistlabel);
        %Prints Figure:
            if ispec == indAF(end)
%                 print(fig.matrixAF,'matrixAF','-dmeta');
                savefig(fig.matrixAF,'TemplateFigs/Fig14b.fig')
                print(fig.matrixAF,'TemplateFigs/Fig14b','-dmeta');
                print(fig.matrixAF,'TemplateFigs/Fig14b','-depsc2');
                print(fig.matrixAF,'TemplateFigs/Fig14b','-dpdf');
            end
        
    end
    
    
%Defines Eurocode Retained Yield Stress Cuve:
    sy_EuroSF = [20,100,200,300,400,500,600,700,800;...
                 1.00,1.00,1.00,1.00,1.00,0.78,0.47,0.23,0.11];
%Recalculates Vector of Ambient-Temperature Parameters:
    s_plateauAmb = s_plateau(4);
%Initializes Counter:
    ctr = 0;
%Initializes Figures:
    fig.EuroSF = figure('name','Retained Mechanical Properties - Eurocode Comparison (Steel Foam)','units','inches','position',[1.5,1.75,5.5,3.75],'paperposition',[1.5,1.75,5.5,3.75]); ax = gca;
%Plots Elastic Data for Steel Foam:
    for ispec = indSF
        %Increments Counter:
            ctr = ctr+1;
        %Unpacks Retained Yield Stress:
        %( xCVal = [ki,ky,ry,ny,dbr,kb,kp,rb,nb,RConval,fvalC] )
            s_retainedRet = s_plateau(ispec)/s_plateauAmb;
        %Selects Relavent Markertype and Color:
            msizefact = 3.0;
        %Plots Retained Quasi-Elastic Modulus:
            figure(fig.EuroSF); ax = gca; %Selects Figure
%             hSF_Euro = scatter(itemp(ispec),s_retainedRet,250/msizefact,'s','markeredgecolor',ax.ColorOrder(2,:),'markerfacecolor',0.75*ax.ColorOrder(2,:),'markerfacealpha',0.50,'linewidth',1.0); hold all;
            hSF_Euro = scatter(itemp(ispec),s_retainedRet,250/msizefact,'s','markeredgecolor','k','markerfacecolor','k','markerfacealpha',0.35,'linewidth',1.0); hold all;
            TSF_Euro(ctr) = itemp(ispec);
            sRetSF_Euro(ctr) = s_retainedRet;
            if ispec == indSF(end)
                p1 = plot(sy_EuroSF(1,:),sy_EuroSF(2,:),'-','color',ax.ColorOrder(1,:),'linewidth',1.5);
                p1 = plot(sy_EuroSF(1,:),sy_EuroSF(2,:),'-','color','k','linewidth',1.5);
%                 ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [-0.025,1.10];
%                 ax.FontSize = 11;
%                 xlabel('Temperature (°C)','fontsize',12);
%                 ylabel('Retention Factor','fontsize',12);
%                 hleg = legend([hSF_Euro,p1],{'Retained Plateau Stress',sprintf('Retained Yield Stress, Bulk\nCarbon Steel (Eurocode)')},'location','southwest');
%                 grid on; box on; drawnow;
%                 print(fig.EuroSF,'EuroSF','-dmeta');
                set(ax,'DefaultAxesColorOrder',[0,0,0]);
                set(ax,'DefaultAxesLineStyleOrder','-|s|o|x|v|>|p|d|:s|:o|:x|:v|:>|:p');
                set(ax, 'DefaultLineLineWidth',1.5);
                set(ax,'DefaultLineMarkerSize',5.0);
                ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [-0.025,1.10];
                set(gca,'FontSize',12);
                hleg = legend([hSF_Euro,p1],{'Retained Plateau Stress',sprintf('Retained Yield Stress, Bulk\nCarbon Steel (Eurocode)')},'location','southwest');
                set(hleg,'FontSize',12,'box','on');   %set legend edges to white
                xlabel('Temperature (°C)','fontname','arial','fontsize',12);
                ylabel('Retention Factor','fontname','arial','fontsize',12);
                set(gca,'Box','on','TickDir','in','XGrid','off','YGrid','off','XColor',[.0 .0 .0],'YColor',[.0 .0 .0],'LineWidth',1);
                savefig(fig.EuroSF,'TemplateFigs/Fig19a.fig')
                print(fig.EuroSF,'TemplateFigs/Fig19a','-dmeta');
                print(fig.EuroSF,'TemplateFigs/Fig19a','-deps2');
                print(fig.EuroSF,'TemplateFigs/Fig19a','-dpdf');
            end
    end
    fprintf('Fig23(a)\n'); TSF_Euro,sRetSF_Euro
    
%Defines Eurocode Retained Yield Stress Cuve:
    sy_EuroAF = [20,100,150,200,250,300,350,550,800;...
                 1.00,0.90,0.75,0.50,0.23,0.11,0.06,0.00,0.00];
%Recalculates Vector of Ambient-Temperature Parameters:
    s_plateauAmb = s_plateau(17);
%Initializes Counter:
    ctr = 0;
%Initializes Figures:
    fig.EuroAF = figure('name','Retained Mechanical Properties - Eurocode Comparison (Steel Foam)','units','inches','position',[1.5,1.75,5.5,3.75],'paperposition',[1.5,1.75,5.5,3.75]); ax = gca;
%Plots Elastic Data for Steel Foam:
    for ispec = indAF
        %Increments Counter:
            ctr = ctr+1;
        %Unpacks Retained Yield Stress:
        %( xCVal = [ki,ky,ry,ny,dbr,kb,kp,rb,nb,RConval,fvalC] )
            s_retainedRet = s_plateau(ispec)/s_plateauAmb;
        %Selects Relavent Markertype and Color:
            msizefact = 3.0;
        %Plots Retained Quasi-Elastic Modulus:
            figure(fig.EuroAF); ax = gca; %Selects Figure
%             hAF_Euro = scatter(itemp(ispec),s_retainedRet,250/msizefact,'s','markeredgecolor',ax.ColorOrder(2,:),'markerfacecolor',0.75*ax.ColorOrder(2,:),'markerfacealpha',0.50,'linewidth',1.0); hold all;
            hAF_Euro = scatter(itemp(ispec),s_retainedRet,250/msizefact,'s','markeredgecolor','k','markerfacecolor','k','markerfacealpha',0.35,'linewidth',1.0); hold all;
            TAF_Euro(ctr) = itemp(ispec);
            sRetAF_Euro(ctr) = s_retainedRet;
            if ispec == indAF(end)
%                 p1 = plot(sy_EuroAF(1,:),sy_EuroAF(2,:),'-','color',ax.ColorOrder(1,:),'linewidth',1.5);
                p1 = plot(sy_EuroAF(1,:),sy_EuroAF(2,:),'-','color','k','linewidth',1.5);
%                 ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [-0.025,1.10];
%                 ax.FontSize = 11;
%                 xlabel('Temperature (°C)','fontsize',12);
%                 ylabel('Retention Factor','fontsize',12);
%                 hleg = legend([hAF_Euro,p1],{'Retained Plateau Stress',sprintf('Retained Yield Stress, Bulk\nAluminum (Eurocode)')},'location','northeast');
%                 grid on; box on; drawnow;
%                 print(fig.EuroAF,'EuroAF','-dmeta');
                set(ax,'DefaultAxesColorOrder',[0,0,0]);
                set(ax,'DefaultAxesLineStyleOrder','-|s|o|x|v|>|p|d|:s|:o|:x|:v|:>|:p');
                set(ax, 'DefaultLineLineWidth',1.5);
                set(ax,'DefaultLineMarkerSize',5.0);
                ax.XLim = [0,1.035*max(itemp)]; ax.YLim = [-0.025,1.10];
                set(gca,'FontSize',12);
                hleg = legend([hAF_Euro,p1],{'Retained Plateau Stress',sprintf('Retained Yield Stress, Bulk\nAluminum (Eurocode)')},'location','northeast');
                set(hleg,'FontSize',12,'box','on');   %set legend edges to white
                xlabel('Temperature (°C)','fontname','arial','fontsize',12);
                ylabel('Retention Factor','fontname','arial','fontsize',12);
                set(gca,'Box','on','TickDir','in','XGrid','off','YGrid','off','XColor',[.0 .0 .0],'YColor',[.0 .0 .0],'LineWidth',1);
                savefig(fig.EuroAF,'TemplateFigs/Fig19b.fig')
                print(fig.EuroAF,'TemplateFigs/Fig19b','-dmeta');
                print(fig.EuroAF,'TemplateFigs/Fig19b','-deps2');
                print(fig.EuroAF,'TemplateFigs/Fig19b','-dpdf');
            end
    end
    fprintf('Fig23(b)\n'); TAF_Euro,sRetAF_Euro
            