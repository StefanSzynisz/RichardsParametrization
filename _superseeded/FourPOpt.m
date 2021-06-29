function [xC,fvalC] = FourPOpt(e,s,ki,ky,ry,ny,visualize)
    
%Destroys Post-Peak Data:
    [~,indmax] = max(s);
    e(indmax+1:end) = []; s(indmax+1:end) = [];
%Defines Objective Function (data - Richard Prediction)
    Pfit = (ki-ky)*e./(1+abs(((ki-ky).*e)/ry).^ny).^(1/ny) + ky*e;
    PfitRes = abs(s-Pfit);

%Initializes Figure and Plots Experimental Data:
    if visualize
        fig.OPT = figure('name','FitOptimized'); ax = gca;
        plot(e,s,'color',[0.35,0.35,0.35],'linewidth',3.0); hold all;
        p1 = plot(e,Pfit,'-','color',ax.ColorOrder(2,:),'linewidth',1.5); hold all;
        a1 = area([e(1);e;e(end);e(1)],[0;PfitRes;0;0],'FaceColor',ax.ColorOrder(2,:),...
            'FaceAlpha',0.50,'EdgeColor',ax.ColorOrder(2,:)); hold all;

        ax.XLim = [0,1.025*max(e)]; ax.YLim = [0,1.15*max(s)];
        ax.FontSize = 11;
        xlabel('Strain (mm/mm)','fontsize',12);
        ylabel('Stress (MPa)','fontsize',12);
        drawnow;
    end

%Pattern Search Algorithm:
    x0 = [ki,ky,ry,ny];                          %Initial Estimates of Parameter Values (i.e., initialization values)
    lb = [0.25*ki, 0.75*ky, 0.75*ry, 0.125*ny];   %Lower-Bound Parameter Values
    ub = [12.00*ki, 1.25*ky, 1.25*ry, 8.00*ny];  %Upper-Bound Parameter Values
%Defines Options:
    opts = optimoptions('fmincon','MaxFunctionEvaluations',8000,'StepTolerance',1.0e-16);
%Constrained Multivariable Optimization
    fprintf('Performing Constrained Multivariable Optimization\n');
%     [xC,fvalC,exitflag] = fmincon(@(x)user_FourParameterObjectiveFunction(x,e,s),x0,[],[],[],[],lb,ub);
    [xC,fvalC] = fmincon(@(x)user_FourParameterObjectiveFunction(x,e,s),x0,[],[],[],[],lb,ub,[],opts);
%Constrained Multivariable Optimization:
    %Unpacks Optimized Parameters:
        xCki = xC(1); xCky = xC(2); xCry = xC(3); xCny = xC(4);
    %Recalculates Fitted Response Curve:
        RCon = (xCki-xCky)*e./(1+abs(((xCki-xCky).*e)/xCry).^xCny).^(1/xCny) + xCky*e;
        RConRes = abs(s-RCon);
    
%Plots Constrained Multivariable Optimization:
    if visualize
        p2 = plot(e,RCon,'-','color',ax.ColorOrder(1,:),'linewidth',2);
        a2 = area([e(1);e;e(end);e(1)],[0;RConRes;0;0],'FaceColor',ax.ColorOrder(1,:),...
            'FaceAlpha',0.50,'EdgeColor',ax.ColorOrder(1,:)); hold all;
        legend([p1,p2,a1,a2],'Initial Guess','Optimized Curve','Initial Residual','Optimized Residual','Location','Northwest');
        grid on; drawnow;
    end
