function [xC,fvalC,RConval] = NinePOpt(e,s,ki,ky,ry,ny,dbr,kb,kp,rb,nb,cspec,visualize)

%Destroys Post-Peak Data:
    [~,indmax] = max(s);
    e(indmax+1:end) = []; s(indmax+1:end) = [];
%Defines Objective Function (data - Richard Prediction)
    Pfit(e<=dbr) = (ki-ky)*e(e<=dbr)./(1+abs(((ki-ky).*e(e<=dbr))/ry).^ny).^(1/ny) + ky*e(e<=dbr);
    Pfitval = (ki-ky)*dbr./(1+abs(((ki-ky).*dbr)/ry).^ny).^(1/ny) + ky*dbr;
    Pfit(e>dbr) = Pfitval + (kb-kp)*(e(e>dbr)-dbr)./(1+abs(((kb-kp).*(e(e>dbr)-dbr))/rb).^nb).^(1/nb) + kp*(e(e>dbr)-dbr);
    PfitRes = abs(s-Pfit');
    
%Initializes Figure and Plots Experimental Data:
    if visualize
        fig.OPT = figure('name',sprintf('%s - Nine Parameter Optimization',cspec)); ax = gca;
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
    
%Constrained Multivariable Optimization:
    %Defines Initial Starting Point:
        x0 = [ki,ky,ry,ny,dbr,kb,kp,rb,nb];  %Initial Estimates of Parameter Values (i.e., initialization values)
    %Defines Upper and Lower Bounds:
        lb = [0.25*ki, 0.50*ky, 0.50*ry, 0.125*ny, 0.75*dbr, 0.50*kb, -0.25*kp, 1.00*rb, 0.001*nb];  %Lower-Bound Parameter Values
        ub = [25.0*ki, 2.00*ky, 2.00*ry, 8.00*ny, 1.25*dbr, 2.00*kb,  4.00*kp, 2.00*rb, 100.00*nb];  %Upper-Bound Parameter Values
    %Defines Options:
        opts = optimoptions('fmincon','MaxFunctionEvaluations',8000,'StepTolerance',1.0e-16);
    %Performs Optimization:
        fprintf('Performing Nine-Parameter Constrained Multivariable Optimization\n');
%         [xC,fvalC,~] = fmincon(@(x)user_NineParameterObjectiveFunction(x,d,P),x0,[],[],[],[],lb,ub);
        [xC,fvalC,~] = fmincon(@(x)user_NineParameterObjectiveFunction(x,e,s),x0,[],[],[],[],lb,ub,[],opts);
        
%Unpacks Constrained Multivariable Optimization:
    %Unpacks Optimized Parameters:
        xCki = xC(1); xCky = xC(2); xCry = xC(3); xCny = xC(4); xCdbr = xC(5); 
        xCkb = xC(6); xCkp = xC(7); xCrb = xC(8); xCnb = xC(9);
    %Recalculates Fitted Response Curve:
        RCon(e<=xCdbr) = (xCki-xCky)*e(e<=xCdbr)./(1+abs(((xCki-xCky).*e(e<=xCdbr))/xCry).^xCny).^(1/xCny) + xCky*e(e<=xCdbr);
        RConval = (xCki-xCky)*xCdbr./(1+abs(((xCki-xCky).*xCdbr)/xCry).^xCny).^(1/xCny) + xCky*xCdbr;
        RCon(e>xCdbr) = RConval + (xCkb-xCkp)*(e(e>xCdbr)-xCdbr)./(1+abs(((xCkb-xCkp).*(e(e>xCdbr)-xCdbr))/xCrb).^xCnb).^(1/xCnb) + xCkp*(e(e>xCdbr)-xCdbr);
        RConRes = abs(s-RCon');
    
%Plots Pattern Search Optimization:
    if visualize
        p2 = plot(e,RCon,'-','color',ax.ColorOrder(1,:),'linewidth',2);
        a2 = area([e(1);e;e(end);e(1)],[0;RConRes;0;0],'FaceColor',ax.ColorOrder(1,:),...
            'FaceAlpha',0.50,'EdgeColor',ax.ColorOrder(1,:)); hold all;
        legend([p1,p2,a1,a2],'Initial Guess','Optimized Curve','Initial Residual','Optimized Residual','Location','Northwest');
        grid on; drawnow;
    end
