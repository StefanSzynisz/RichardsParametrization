function f = user_FourParameterObjectiveFunction(x,d,P)

%Unpacks Parameters
    ki = x(1); ky = x(2); ry = x(3); ny = x(4); %dbr = x(5);
%     kb = x(6); kp = x(7); rb = x(8); nb = x(9);
% %Calculates Initial Estimate of Slip Deformation:
%     do_temp = (kb*dbr+ry)/(kb-ky);
%Defines Linear Displacement Vector (used only for calculating intersection
%point between nonlinear curves):
%     dvec = linspace(do_temp-0.25,do_temp+0.25,50);
%Calculates Exact Value of Slip Deformation:
%     R = (ki-ky)*dvec./(1+abs(((ki-ky).*dvec)/ry).^ny).^(1/ny) + ky*dvec;
%     R2 = (kb-kp)*(dvec-dbr)./(1+abs(((kb-kp).*(dvec-dbr))/rb).^nb).^(1/nb) + kp*(dvec-dbr);
%     [do,~] = intersections(dvec,R1,dvec,R2,0);
%     if length(do)>1; do = do(1); end %Handles possibility of more than one intersection
%     if isempty(do); do = do_temp; end %Handles possibility of no intersections
%Richard Equation:
    R = (ki-ky)*d./(1+abs(((ki-ky).*d)/ry).^ny).^(1/ny) + ky*d;
%     R(d>do) = (kb-kp)*(d(d>do)-dbr)./(1+abs(((kb-kp).*(d(d>do)-dbr))/rb).^nb).^(1/nb) + kp*(d(d>do)-dbr);
%Functional:
    f = trapz(d,abs(P-R)); %transpose needed because P and R are both column vectors
