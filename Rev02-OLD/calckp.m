function pinit = calckp(pdata,indky,visualize)

%Initial Data with Load less than Load Limit:
    indkp = indky(end)+1:length(pdata.d);
    dkp = pdata.d(indkp); Pkp = pdata.P(indkp);
%Fits Least-Squares Linear Regression to Bearing Stiffness Data:
    pinit = polyfit(dkp,Pkp,1);  %Linear regression to bearing stiffness data
%Plots Data:
    if visualize
        figure;
        ax = gca; hold all;
        p1 = plot(dkp,Pkp);
        plot(dkp,Pkp,'-','color',p1.Color);
        plot(dkp,pinit(1)*dkp+pinit(2),'--','color',p1.Color);
        ax.YLim = [0,1.15*max(Pkp)];
    end
