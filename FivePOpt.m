function [xE,fvalE] = FivePOpt(e,s,ki,ky,ry,ny,eo,visualize)
    
%Destroys Post-Peak Data:
    [~,indmax] = max(s);
    e(indmax+1:end) = []; s(indmax+1:end) = [];
%Defines Objective Function (data - Richard Prediction)
    Pfit = (ki-ky)*(e-eo)./(1+abs(((ki-ky).*(e-eo))/ry).^ny).^(1/ny) + ky*(e-eo);
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
    x0 = [ki,ky,ry,ny,0];                                 %Initial Estimates of Parameter Values (i.e., initialization values)
    lb = [0.50*ki, 0.20*ky, 0.15*ry, 0.125*ny, 4.0*eo];    %Lower-Bound Parameter Values
    ub = [2.00*ki, 50.00*ky, 4.00*ry, 15.00*ny, -2.0*eo];  %Upper-Bound Parameter Values
% %Constrained Multivariable Optimization:
%     fprintf('Performing Five-Parameter Constrained Multivariable Optimization\n');
%     opts = optimoptions('fmincon','MaxFunctionEvaluations',16000,'StepTolerance',1.0e-18,'MaxIterations',5000);
%     [xC,fvalC] = fmincon(@(x)user_FiveParameterObjectiveFunction(x,e,s),x0,[],[],[],[],lb,ub,[],opts);
%Particle Swarm:
    fprintf('Performing Five-Parameter Particle Swarm Optimization\n');
    opts = optimoptions('particleswarm','SwarmSize',300,'FunctionTolerance',1.0e-18,'MaxIterations',5000);
    [xE,fvalE] = particleswarm(@(x)user_FiveParameterObjectiveFunction(x,e,s),length(x0),lb,ub,opts);
% %Pattern Search Algorithm:
%     fprintf('Performing Five-Parameter Pattern Search Optimization\n');
%     [xP,fvalP] = patternsearch(@(x)user_FiveParameterObjectiveFunction(x,e,s),x0);
% %Global Search Algorithm:
%     fprintf('Performing Five-Parameter Global Search Optimization\n');
%     opts = optimoptions('fmincon','MaxFunctionEvaluations',16000,'StepTolerance',1.0e-18,'MaxIterations',5000);
%     problem = createOptimProblem('fmincon','objective',@(x)user_FiveParameterObjectiveFunction(x,e,s),'x0',x0,'lb',lb,'ub',ub,'options',opts);
%     [xG,fvalG] = run(GlobalSearch,problem);
    
% %Aggregates Parameter Sets and Functional Values:
%     all_fval = [fvalC,fvalR,fvalP,fvalG];
%     all_x = [xC;xR;xP;xG];
% %Selects Parameters yielding the Least Functional:
%     [fvalE,indE] = min(all_fval);
%     xE = all_x(indE,:);
%     all_fval,all_x
%     indE %,fvalE,xE
    
%Constrained Multivariable Optimization:
    %Unpacks Optimized Parameters:
        xEki = xE(1); xEky = xE(2); xEry = xE(3); xEny = xE(4); xEeo = xE(5);
    %Recalculates Fitted Response Curve:
        RCon = (xEki-xEky)*(e-xEeo)./(1+abs(((xEki-xEky).*(e-xEeo))/xEry).^xEny).^(1/xEny) + xEky*(e-xEeo);
        RConRes = abs(s-RCon);
    
%Plots Constrained Multivariable Optimization:
    if visualize
        p2 = plot(e,RCon,'-','color',ax.ColorOrder(1,:),'linewidth',2);
        a2 = area([e(1);e;e(end);e(1)],[0;RConRes;0;0],'FaceColor',ax.ColorOrder(1,:),...
            'FaceAlpha',0.50,'EdgeColor',ax.ColorOrder(1,:)); hold all;
        legend([p1,p2,a1,a2],'Initial Guess','Optimized Curve','Initial Residual','Optimized Residual','Location','Northwest');
        grid on; drawnow;
    end
