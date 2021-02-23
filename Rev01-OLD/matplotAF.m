% function [fig,h,maxVd,maxFn] = matplot(fig,h,comp,spec,cspecind,Vd,Vn,Delta,Vi,npspec,maxVd,maxFn,compspecs,expprops)
function [fig,h,max_x,max_y] = matplotAF(fig,h,ictr,x1,y1,x2,y2,max_x,max_y,nspec,ifile,varargin)

%Assigns Variable List:
    vlist = varargin{1};
%Records Maximum Values:
    max_x(ictr) = max(max(x1),max(x2));
    max_y(ictr) = max(max(y1),max(y2));
    
%Defines Number of Rows and Columns in MatPlot:
%     nirow = ceil(sqrt(npspec)); njcol = ceil(sqrt(npspec)); %Creates SQUARE Matrix Plot
    nirow = 3; njcol = 3; %Allows Overwriting of Matrix Plot Configuration
%Defines Plot Handle:
    h(ictr) = subplot(nirow,njcol,ictr); ax = gca;

%Plots Data:
    %Plots Vertical Force at Column Face (Experimental):
        plot(x1,y1,'-','linewidth',3.25,'color',[0.65,0.65,0.65]); hold all;
        plot(x2,y2,'-.','linewidth',1.25,'color','k'); hold all;
        drawnow;
                
        alphabet = ['ABCDEFGHIJKLMNOPQRSTUVWXYZ'];
        xlswrite('MatplotData-Rev02.xlsx',{sprintf('subplot(%d,%d,%d):\n',nirow,njcol,ictr)},'AF_Meas',sprintf('%s1',alphabet(2*(ictr-1)+1)));
        xlswrite('MatplotData-Rev02.xlsx',{'x1'},'AF_Meas',sprintf('%s2',alphabet(2*(ictr-1)+1)));
        xlswrite('MatplotData-Rev02.xlsx',{'y1'},'AF_Meas',sprintf('%s2',alphabet(2*(ictr-1)+2)));
        xlswrite('MatplotData-Rev02.xlsx',x1,'AF_Meas',sprintf('%s3',alphabet(2*(ictr-1)+1)));
        xlswrite('MatplotData-Rev02.xlsx',y1,'AF_Meas',sprintf('%s3',alphabet(2*(ictr-1)+2)));
        
        xlswrite('MatplotData-Rev02.xlsx',{sprintf('subplot(%d,%d,%d):\n',nirow,njcol,ictr)},'AF_Fitted',sprintf('%s1',alphabet(2*(ictr-1)+1)));
        xlswrite('MatplotData-Rev02.xlsx',{'x2'},'AF_Fitted',sprintf('%s2',alphabet(2*(ictr-1)+1)));
        xlswrite('MatplotData-Rev02.xlsx',{'y2'},'AF_Fitted',sprintf('%s2',alphabet(2*(ictr-1)+2)));
        xlswrite('MatplotData-Rev02.xlsx',x2,'AF_Fitted',sprintf('%s3',alphabet(2*(ictr-1)+1)));
        xlswrite('MatplotData-Rev02.xlsx',y2,'AF_Fitted',sprintf('%s3',alphabet(2*(ictr-1)+2)));
        
if ictr == nspec
    for secspec = 1:nspec
    %Computes Maximum Values:
        max_x = max(max_x);
        max_y = max(max_y);
    %Creates Matrix Plot Configuration:
        %Defines Uniform Axis Limits:
            axis(h,[0,0.800,0,40.0]);
        %Defines Font for Numerical Labels:
            set(h(secspec),'fontname','arial','fontsize',9);
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
            xspanr = xspan/1.200;
            yspanr = yspan/1.200;
    
    %Expands Plots:
        for irow = 1:nirow
            for jcol = 1:njcol
                if (irow-1)*njcol+jcol <= nspec
                    %Defines New Axis Position:
                        xpos = xminpos+(jcol-1)*xspan;
                        ypos = ymaxpos-irow*yspan;
                    %Allows Fine-Tuned User Adjustments:
                        xadjust = 0.00; yadjust = 0.035;
                    %Sets New Position:
                        set(h((irow-1)*njcol+jcol),...
                            'position',[xpos+xadjust,ypos+yadjust,xspanr,yspanr]);
                end
            end
        end

    %Annotates Label Onto Plot:
        for secspec = 1:nspec
            %Sets Current Axis:
                axes(h(secspec)); %#ok<LAXES>
            %Restricts Axis Labels from using Scientific Notation:
                ax = gca; ax.XRuler.Exponent = 0;
            %Annotates Plot:
                text(0.02,36.5,sprintf('%s',vlist{secspec}),'fontname','arial','fontsize',9,...
                    'fontweight','bold','horizontalalignment','left','verticalalignment','middle','interpreter','none');
                set(gca,'xtick',0:0.20:1.00);
                set(gca,'ytick',0:10:40);
        end
    %Applies Super-Labels:
        [~,hx] = suplabel('Engineering Strain (mm/mm)','x'); %For Journal Article);
        set(hx,'fontname','arial','fontsize',14); %For BA Journal Article
        [~,hy] = suplabel('Engineering Stress (MPa)','y');
        set(hy,'fontname','arial','fontsize',14);
    %Adjusts Super-Label Positions:
        set(hx,'position',get(hx,'position')+[0,0.035,0]); %(x-label)
        set(hy,'position',get(hy,'position')+[0.030,0,0]); %(y-label)
        hL = columnlegend(2,{'Exp. Stress-Strain Data','Eq. (1) with Fitted Parameters'},'location','top');
    %Move the Legend
        set(hL,'FontSize',14);
        currentPosition = get(hL,'Position');
        newPosition = [0.1750    0.8900    0.6500    0.0639];
        newUnits = 'normalized';
        set(hL,'Position', newPosition,'Units', newUnits);

end

