% function [fig,h,maxVd,maxFn] = matplot(fig,h,comp,spec,cspecind,Vd,Vn,Delta,Vi,npspec,maxVd,maxFn,compspecs,expprops)
function [fig,h,max_x,max_y] = matplot(fig,h,spec,x1,y1,x2,y2,max_x,max_y,nspec,ifile)

% vlistr = varargin{1};
% %Plots Data as Matrix:
%     if spec == 1; fig.matplot = figure('units','inches','position',1.75*[0.5,0.75,6.0,4.25],...
%             'paperposition',1.75*[0.5,0.75,6.0,4.25]);
%     end
%     figure(fig.matplot)
%Records Maximum Values:
    max_x(spec) = max(max(x1),max(x2));
    max_y(spec) = max(max(y1),max(y2));
    
%Defines Number of Rows and Columns in MatPlot:
%     nirow = ceil(sqrt(npspec)); njcol = ceil(sqrt(npspec)); %Creates SQUARE Matrix Plot
    nirow = 5; njcol = 4; %Allows Overwriting of Matrix Plot Configuration
%Defines Plot Handle:
    h(spec) = subplot(nirow,njcol,spec); ax = gca;
%Plots Data:
    %Plots Vertical Force at Column Face (Experimental):
%         in2mm = 25.4; kip2kN = 4.448221615;  %Converts kips to kN
            in2mm = 25.4; %Converts in to mm
            kip2kN = 4.44822159999924; %Converts kip to kN
%         plot(Vd,Vn,'linewidth',3,'color',[0.60,0.60,0.60]); hold all; %English Units:
%         plot(in2mm*x1,kip2kN*y1,'linewidth',1.75,'color',[0.60,0.60,0.60]); hold all;
        plot(in2mm*x1,kip2kN*y1,'-.','linewidth',1.75,'color',ax.ColorOrder(2,:)); hold all;
        plot(in2mm*x2,kip2kN*y2,'linewidth',1.75,'color',ax.ColorOrder(1,:)); hold all;
    %Plots Vertical Force at Column Face (Model):
%         ax = gca; ax.ColorOrderIndex = 1; %Resets Color Order
%         plot(Delta,Vi,'linewidth',3); %English Units:
%         plot(in2mm*Delta,kip2kN*Vi,'linewidth',3); %English Units:
        drawnow;
        
if spec == nspec
    for secspec = 1:nspec
    %Computes Maximum Values:
        max_x = max(max_x);
        max_y = max(max_y);
    %Creates Matrix Plot Configuration:
        %Defines Uniform Axis Limits:
            axis(h,[in2mm*[-0.025*max_x,12.0/in2mm],kip2kN*[-0.025*max_y,750/kip2kN]]); %25 mm diameter A490 Bolts
            axis(h,[in2mm*[-0.025*max_x,12.0/in2mm],kip2kN*[-0.025*max_y,450/kip2kN]]); %19 mm diameter A490 Bolts
            axis(h,[in2mm*[-0.025*max_x,15.0/in2mm],kip2kN*[-0.025*max_y,600/kip2kN]]); %22 mm diameter A490 Bolts
        %Defines Font for Numerical Labels:
            set(h(secspec),'fontname','arial','fontsize',10);
        %Ensures that Plots have Tick Marks and Grid:
            grid(h(secspec),'on');
            box(h(secspec),'on');
        %Coordinates Axis Labels:
            if mod(secspec,njcol) == 1
                %Plot is on the Left-Hand-Side:
                    if secspec <= nspec-njcol
                        set(h(secspec),'xticklabel',[]);
                    end
            else
                %Plot is Not on the Left-Hand-Side:
                    if secspec <= nspec-njcol
                        %Plot is Interior (Needs no Labels):
                            set(h(secspec),'xticklabel',[],'yticklabel',[]);
                    else
                        %Plot is Bottom Exterior (Needs Labels):
                            set(h(secspec),'yticklabel',[]);
                    end
            end
    end
    
    %Determines Limits for Adjusting Axis Sizes:
        %Determines Left-Hand-Top Position:
            ltpos = get(h(1),'position');
            xminpos = ltpos(1);
            ymaxpos = ltpos(2)+ltpos(4);
        %Determines Right-Hand-Top Position:
            rtpos = get(h(njcol),'position');
            xmaxpos = rtpos(1)+rtpos(3);
        %Determines Left-Hand-Bottom Plot Number:
            for pos = nspec-njcol:nspec
                if mod(pos,njcol) == 1
                    lbnum = secspec;
                end
            end
        %Determines Left-Hand-Bottom Position:
            lbpos = get(h(lbnum),'position');
            yminpos = lbpos(2);
        %Defines Equal Span Lengths for each Subplot:
            xspan = (xmaxpos-xminpos)/njcol;
            yspan = (ymaxpos-yminpos)/nirow;
        %Defines Reduced xspan and yspan to leave White Space between Plots:
%             xspanr = xspan/1.075;
            xspanr = xspan/1.130; %Metric Units
            yspanr = yspan/1.065;
    
    %Expands Plots:
        for irow = 1:nirow
            for jcol = 1:njcol
                if (irow-1)*njcol+jcol <= nspec
                    %Defines New Axis Position:
                        xpos = xminpos+(jcol-1)*xspan;
                        ypos = ymaxpos-irow*yspan;
                    %Allows Fine-Tuned User Adjustments:
                        xadjust = 0.00; yadjust = 0.00;
                    %Sets New Position:
                        set(h((irow-1)*njcol+jcol),...
                            'position',[xpos+xadjust,ypos+yadjust,xspanr,yspanr]);
                end
            end
        end
        
    %Defines Alternate Specimen Labels:
        if ifile == 1
        speclabels = {'25A325T20-1','25A325T20-2','25A325T20-3',...
                      '25A325T200-2','25A325T200-3',...
                      '25A325T400-1','25A325T400-2','25A325T400-3',...
                      '25A325T500-1','25A325T500-2','25A325T500-3',...
                      '25A325T600-1','25A325T600-2','25A325T600-3'};
        else
        speclabels = {'25A490T20-1','25A490T20-2','25A490T20-3','25A490T20-4',...
                      '25A490T200-1','25A490T200-2','25A490T200-3',...
                      '25A490T400-1','25A490T400-2','25A490T400-3',...
                      '25A490T500-1','25A490T500-2','25A490T500-3',...
                      '25A490T600-1','25A490T600-2','25A490T600-3'};
        end
        speclabels = strrep(vlistr,'_','-');
    %Annotates Label Onto Plot:
        for secspec = 1:nspec
            %Sets Current Axis:
                axes(h(secspec)); %#ok<LAXES>
            %Annotates Plot:
%                 text(8.50,50,sprintf('%s',speclabels{secspec}),'fontname','arial','fontsize',9,...
%                     'fontweight','bold','horizontalalignment','right','verticalalignment','middle'); %A325 bolts
                text(11.50,50,sprintf('%s',speclabels{secspec}),'fontname','arial','fontsize',9,...
                    'fontweight','bold','horizontalalignment','right','verticalalignment','middle'); %A490 bolts
%                 set(gca,'xtick',0:1:20); %A325 bolts
                set(gca,'xtick',0:2:20); %A490 bolts
                set(gca,'ytick',0:100:1200); %25 mm diameter bolts For Horizontal Force at Column Face (Metric Units)
                set(gca,'ytick',0:50:1200); %19 mm diameter bolts For Horizontal Force at Column Face (Metric Units)
                set(gca,'ytick',0:100:1200); %22 mm diameter bolts For Horizontal Force at Column Face (Metric Units)
        end
    %Applies Super-Labels:
        [~,hx] = suplabel('Deformation, \delta (mm)','x'); %For Journal Article);
        set(hx,'fontname','arial','fontsize',14); %For BA Journal Article
        [~,hy] = suplabel('Load, P (kN)','y');
        set(hy,'fontname','arial','fontsize',14);
%     %Adjusts Super-Label Positions:
        set(hx,'position',get(hx,'position')+[0,0.035,0]); %(x-label)
        set(hy,'position',get(hy,'position')+[0.030,0,0]); %(y-label)
%         legend('Uncorrected Data','Corrected Data','location','top;');
        % Construct a Legend with the data from the sub-plots
%         hL = columnlegend(2,{'Uncorrected Data','Corrected Data'},'location','top');
        hL = columnlegend(2,{'Data Excluded from Parameter Fitting','Data Used in Parameter Fitting'},'location','top');
    %Move the Legend
        set(hL,'FontSize',14);
        currentPosition = get(hL,'Position');
%         newPosition = [currentPosition(1) 0.885 currentPosition(3) currentPosition(4)];
%         newPosition = [0.3250    0.8850    0.3434    0.0639];
        newPosition = [0.1750    0.8900    0.6500    0.0639];
        newUnits = 'normalized';
        set(hL,'Position', newPosition,'Units', newUnits);


%     %Prints Figure:
%         print(gcf,'-djpeg','-r400','SPSMatPlotV'); %For BA Journal Article ONLY
%         print(gcf,'-depsc','SPSMatPlotV'); %For BA Journal Article ONLY
%         print(gcf,'-djpeg','-r400','SPSMatPlotVMetric'); %For BA Journal Article ONLY
%         print(gcf,'-depsc','SPSMatPlotVMetric'); %For BA Journal Article ONLY
%         print(gcf,'-djpeg','-r400','SPSMatPlotT'); %For BA Journal Article ONLY
%         print(gcf,'-depsc','SPSMatPlotT'); %For BA Journal Article ONLY
%         print(gcf,'-djpeg','-r400','SPSMatPlotTMetric'); %For BA Journal Article ONLY
%         print(gcf,'-depsc','SPSMatPlotTMetric'); %For BA Journal Article ONLY
end

