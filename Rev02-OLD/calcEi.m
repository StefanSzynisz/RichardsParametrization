function [pinit,indEi] = calcEi(e,s,cspec,visualize)

%Defines Average Area:
    AvgArea = 485.0;
%Locates Data with Load of Less than 1000 kN:
%     figure; plot(e,s); hold all;
    StressLim = 800.0/AvgArea; %kN
    if strcmp(cspec,'SF_T700C_15')
        StressLim = 575.0/AvgArea;
    elseif strcmp(cspec,'AF_T500C_15')
        StressLim = 400.0/AvgArea;
%         s(100:120)
%         mean([s(100:105)])
%         [s(100):s(105)]
        for k = 105:107; s(k) = mean([s(85:k)]); end
    end
%     s(100:120)
%Initial Data with Load less than Load Limit:
    indEi = find(s<=StressLim);
%     indEi
%     plot(e,s); hold all;
    eEi = e(indEi); sEi = s(indEi);
%     plot(eEi,sEi,'ro');
%     pause
%Fits Least-Squares Linear Regression to Bearing Stiffness Data:
    pinit = polyfit(eEi,sEi,1);  %Linear regression to initial modulus of elasticity data
    
%Plots Data:
    if visualize
        figure;
        ax = gca; hold all;
        p1 = plot(eEi,sEi);
        plot(eEi,sEi,'o','color',p1.Color);
        plot(eEi,pinit(1)*eEi+pinit(2),'--','color',p1.Color);
        ax.YLim = [0,1.15*max(sEi)];
    end
    