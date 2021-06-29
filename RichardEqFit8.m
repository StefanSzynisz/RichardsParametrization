function [x8,fvalx8] = RichardEqFit8(e,s,optAlgorithm,varargin)

%%RichardEq function documentation:
% [h =] RichardEq(e, s, visualize [true or false])
%   e - specimen's engineering strain, e.g., in units of mm/mm or in/in
%   s - specimen's engineering stress, e.g., in units of MPa or ksi
%   true or 1 - plot toggle, visualize, is set to true
%   false or 0 - plot toggle, visualize, is set to false
%
%  Stress and strain signals can be passed into function as row vectors or
%   column vectors. For consistency in processing, stress and strain data
%   are formatted into column vectors.
%
%  Algorithm performs optimizes Eight-Parameter Richard Equation to fit
%   input stress-strain curve. The algorithm is made up of three primary
%   steps:
%     (1) An estimate of the yield stress is calculated by the 0.2% offset
%   strain method, which is regularly used in mechanical, civil, and
%   structural engineering applications to determine the yield strength of
%   ductile metals;
%     (2) A four-parameter optimization is performed using fmincon to fit the
%   initial portion of the stress stain curve (i.e., the portion of the
%   stress-strain curve prior to densification. These four parameters are
%   then used in initializing the eight-parameter optimization.
%     (3) An eight-parameter optimization is performed using one of Matlab's
%   internally-available optimization algorithms to fit the entire stress-
%   stain curve, up to its peak load. It should be noted that options
%   'particleswarm', 'patternsearch', and 'globalsearch' require Matlab's
%   Global Optimization Toolbox, while options 'fminunc', 'fminsearch',
%   'fmincon', and 'fsolve' only require Matlab's Optimization Toolbox.

%%
%Initializes value of plot toggle:
    visualize = false(1,1);
%Handles optional arguments in:
    if nargin == 4
        if varargin{1}
            visualize = true(1,1); %toggle to control plotting
        end
    end

%%
%Transforms data into column vectors, and prepares data for curve-fitting,
%using Matlab's internal function prepareCurveData():
    [e,s] = prepareCurveData(e,s);

%%
%Calculates an initial estimate for initial modulus of elasticty, Ei, based
%on least-squares linear regression of the initial elastic portion of the
%stress-strain response, and where the limit of elastic behavior is
%determined by calculating the 0.2% offset yield stress. 

%Defines strain offset:
    eOffset = 0.2/100; %units of percent strain
%Determines a crude estimate of the modulus of elasticity, by calculating
%the slope between the first two data points:
    Eiguess = (s(2)-s(1))/(e(2)-e(1));
%Defines 0.2% offset line:
    ELine  = Eiguess*(e-eOffset);
%Finds 0.2% offset yield stress, eyOffset, by the first intersection
%between the 0.2% offset line and the engineering stress-strain curve:
    [eOffsetVec,~] = intersections(e,s,e,ELine,0);
    ey = eOffsetVec(1);
%Partitions elastic data (i.e., data with strain values less than the 0.2%
%offset strain) from the full stress-strain curve:
    eEi = e(e<ey); %elastic portion of the strain
    sEi = s(e<ey); %elastic portion of the stress
%Calculates a final estimate of the initial modulus of elasticity Ei
%Least-Squares Linear Regression to Bearing Stiffness Data:
    regressE = polyfit(eEi,sEi,1);  %%linear regression using Matlab's polyfit function
    Ei = regressE(1); %modulus of elasticity taken as slope of linear regression

        
%%
%Partitions off the "plastic" portion of the stress-strain curve data for
%use in calculating the plastic modulus and yield reference load. The
%plastic portion of the stress-strain data is defined as those data with
%strains between the 0.2% offset yield strain, ey, and the densification
%strain, ebr.

%Determines "plastic" portion of the stress-strain curve data:
    ebr = 0.35;                  %estimate of densification strain
    eEp = e(e >= ey & e < ebr);  %"plastic" portion of the strain
    sEp = s(e >= ey & e < ebr);  %"plastic" portion of the stress
%Fits Least-Squares Linear Regression to Bearing Stiffness Data:
    linregP = polyfit(eEp,sEp,1);  %Linear regression to slip stiffness data
    Ep = linregP(1);
    sy = linregP(2);
%Initializes Shape Factor (1.5 represents a typical value for Richard
%Equation shape factor ny):
    ny = 1.5;
        
%%
%Performs Four-Parameter Optimization to Initialize Eight-Parameter
%Optimization: (i.e., four-parameter optimization provides initial
%conditions for more-advanced eight-parameter optimization)

%Partitions off portion of the stress-strain curve data up through
%densification strain, ebr:
    e4P = e(e<ebr); %portion of strain up to densification strain, ebr
    s4P = s(e<ebr); %portion of stress up to densification strain, ebr
        
%Performs optimization:
    %Starting point for optimization algorithm (i.e., initialization value
    %for each parameter required in the optimization)
        x40 = [Ei,Ep,sy,ny];  %best-guess estimates of parameter values
    %Defines Upper and Lower Bounds:
        x4lb = [0.10*Ei, 0.10*Ep, 0.10*sy, 0.10*ny];      %reasonable lower-bound parameter values
        x4ub = [10.00*Ei, 10.00*Ep, 10.00*sy, 10.00*ny];  %reasonable upper-bound parameter values
    %Defines Optimization Options:
        opts = optimoptions('fmincon',...
            'MaxFunctionEvaluations',8000,...
            'StepTolerance',1.0e-12);
    %Performs constrained four-parameter multivariable optimization using
    %Matlab's internal function fmincon:
        x4 = fmincon(@(x)user_ObjFunct4(x,e4P,s4P),x40,[],[],[],[],x4lb,x4ub,[],opts);
    
%%
%Performs eight-parameter optimization to determine final Richard Equation
%fit to stress-strain data (e, s)

%Initializes Additional Required Parameters:
    ebr = 0.35;                     %estimate of densification strain
    Eb = 2*x4(2);                   %initial modulus of portion of fitted Richard curve beyond densification
                                    % point, estimated as 2*Ep, where Ep is the plastic modulus 
    Ed = max((1/1000)*x4(1),2*Eb);  %densification modulus, estimated as the maximum between (1/1000)*Ei and 2*Ep,
                                    % where Ei and Ep is the elastic and plastic modulus, respectively
    sb = x4(3);                     %reference load for portion of Richard curve beyond densification point
    nb = (1/2)*x4(4);               %Shape parameter of densifying portion of curve, estimated as (1/2)*ny, or half
                                    % the value of the shape parameter of the elastic portion of the stress strain curve
                                    
%Destroys post-peak data (i.e., data taken while the specimen is failing):
    [~,indmax] = max(s);
    e8P = e(1:indmax); %portion of strain up to peak stress, used for performing eight-parameter optimization
    s8P = s(1:indmax); %portion of stress up to peak stress, used for performing eight-parameter optimization

%Constrained Multivariable Optimization:
    %Initial Estimates of Parameter Values (i.e., initialization values)
        x8P0 = [x4(1),x4(2),x4(3),x4(4),ebr,Ed,sb,nb];  %initialization values for eight-parameter optimization
    %Defines Upper and Lower Bounds:
        x8Plb = [0.80*x4(1), 0.25*x4(2), 0.67*x4(3), 0.67*x4(4), 0.50*ebr, Eb, 0.85*sb, 0.02*nb];      %reasonable lower-bound parameter values
        x8Pub = [1.20*x4(1), 4.00*x4(2), 1.50*x4(3), 1.50*x4(4), e8P(end), 8.00*Ed, 4.00*sb, 8.0*nb];  %reasonable upper-bound parameter values
    %Performs constrained eight-parameter multivariable optimization using
    %Matlab's internal function fmincon:
    switch optAlgorithm
        case {'fminunc'}
            [x8,fvalx8] = fminunc(@(x)user_ObjFunct8(x,e,s),x8P0);
        case {'fminsearch'}
            [x8,fvalx8] = fminunc(@(x)user_ObjFunct8(x,e,s),x8P0);
        case {'fmincon'}
            [x8,fvalx8] = fmincon(@(x)user_ObjFunct8(x,e,s),x8P0,[],[],[],[],x8Plb,x8Pub);
        case {'fsolve'}
            opts = optimoptions('fsolve','Algorithm','levenberg-marquardt');
            [x8,fvalx8] = fsolve(@(x)user_ObjFunct8(x,e,s),x8P0,opts);
        case {'particleswarm'}
            [x8,fvalx8] = particleswarm(@(x)user_ObjFunct8(x,e,s),8,x8Plb,x8Pub,opts);
        case {'patternsearch'}
            [x8,fvalx8] = patternsearch(@(x)user_ObjFunct8(x,e,s),x8P0);
        case {'global','Global','globalsearch','GlobalSearch'}
            problem = createOptimProblem('fmincon','objective',@(x)user_ObjFunct8(x,e,s),'x0',x8P0,'lb',x8Plb,'ub',x8Pub,'options',opts);
            [x8,fvalx8] = run(GlobalSearch,problem);
        otherwise
            error('An appropriate optimization algorithm must be selected.')
    end

%%
%Unpacks optimized parameters, which were determined in previous step by
%eight-paraemter constrained multivariable optimization:
    x8Ei = x8(1); x8Ep = x8(2); x8sy = x8(3); x8ny = x8(4);
    x8ebr = x8(5); x8Ed = x8(6); x8sb = x8(7); x8nb = x8(8);
%Calculates fitted Richard Equation response curve:
    %Initializes Richard Equation fit:
        R8Pfit = zeros(size(e8P));
    %Constructs Richard Equation fits:
        R8Pfit(e8P<=x8ebr) = (x8Ei-x8Ep)*e8P(e8P<=x8ebr)./(1+abs(((x8Ei-x8Ep).*e8P(e8P<=x8ebr))/x8sy).^x8ny).^(1/x8ny) + x8Ep*e8P(e8P<=x8ebr);
        R8PfitInfl = (x8Ei-x8Ep)*x8ebr./(1+abs(((x8Ei-x8Ep).*x8ebr)/x8sy).^x8ny).^(1/x8ny) + x8Ep*x8ebr;
        R8Pfit(e8P>x8ebr) = R8PfitInfl + (x8Ep-x8Ed)*(e8P(e8P>x8ebr)-x8ebr)./(1+abs(((x8Ep-x8Ed).*(e8P(e8P>x8ebr)-x8ebr))/x8sb).^x8nb).^(1/x8nb) + x8Ed*(e8P(e8P>x8ebr)-x8ebr);
    %Calculates Residual between Fitted Curve and Data:
        R8PfitRes = abs(s8P-R8Pfit);

%Initializes Figure and Plots Richard Equation fit to Data:
    if visualize
        figure('name','Eight-Parameter Richard Equation Optimization',...
            'units','inches','position',[9.0,1.75,7.5,4.25]); ax = gca;
        plot(e,s,'color',[0.65,0.65,0.65],'linewidth',3.0); hold all;
        pexp = plot(e8P,s8P,'color',[0.35,0.35,0.35],'linewidth',3.0); hold all;
        pfit = plot(e8P,R8Pfit,'-','color',ax.ColorOrder(1,:),'linewidth',1.5);
        afit = area([e8P(1);e8P;e8P(end);e8P(1)],[0;R8PfitRes;0;0],'FaceColor',ax.ColorOrder(1,:),...
            'FaceAlpha',0.50,'EdgeColor',ax.ColorOrder(1,:)); hold all;
        ax.XLim = [0,1.025*max(e)]; ax.YLim = [0,1.10*max(s)];
        title('Eight-Parameter Richard Equation Optimization')
        xlabel('Strain (e.g., mm/mm or in/in)');
        ylabel('Stress (e.g., MPa or ksi)');
        hleg = legend([pexp,pfit,afit],'Data','Optimized Curve','Optimized Residual','Location','NorthEastOutside');
        annotation('textbox',hleg.Position+[0.00,-hleg.Position(4)-0.01,0.00,0.00],'String',...
            {'Richard Eq. Param.:',sprintf('  E_i = %1.1f',x8(1)),...
                                   sprintf('  E_p = %1.2f',x8(2)),...
                                   sprintf('  s_y = %1.1f',x8(3)),...
                                   sprintf('  n_y = %1.2f',x8(4)),...
                                   sprintf('  e_{br} = %1.2f',x8(5)),...
                                   sprintf('  E_d = %1.1f',x8(6)),...
                                   sprintf('  s_b = %1.1f',x8(7)),...
                                   sprintf('  n_b = %1.2f',x8(8))},...
            'FitBoxToText','on','BackgroundColor',[1 1 1],'FontSize',10,'FontAngle','italic');
        grid on; drawnow;
    end
