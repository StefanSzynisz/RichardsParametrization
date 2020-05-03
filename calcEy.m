function pinit = calcEy(e,s,indEi,visualize)

%Defines Yield Portion of Data:
    strainLim = 15.0/50; %mm/mm -- strain
%Initial Data with Load less than Load Limit:
    indEy = find(e<=strainLim);
    eEy = e(indEi(end)+1:indEy(end)); sEy = s(indEi(end)+1:indEy(end));
%Fits Least-Squares Linear Regression to Bearing Stiffness Data:
    pinit = polyfit(eEy,sEy,1);  %Linear regression to slip stiffness data

%Plots Data:
    if visualize
        figure;
        ax = gca; hold all;
        p1 = plot(eEy,sEy);
        plot(eEy,pinit(1)*eEy+pinit(2),'--','color',p1.Color);
        ax.YLim = [0,1.15*max(sEy)];
    end
    
    