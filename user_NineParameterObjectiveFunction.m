function f = user_NineParameterObjectiveFunction(x,d,P)

%Unpacks Parameters
    ki = x(1); ky = x(2); ry = x(3); ny = x(4); dbr = x(5);
    kb = x(6); kp = x(7); rb = x(8); nb = x(9);
% %Calculates Initial Estimate of Slip Deformation:
%     do_temp = (kb*dbr+ry)/(kb-ky);
%Defines Linear Displacement Vector (used only for calculating intersection
%point between nonlinear curves):
%     dvec = linspace(do_temp-0.25,do_temp+0.25,50);
% %Calculates Exact Value of Slip Deformation:
%     R1 = (ki-ky)*dvec./(1+abs(((ki-ky).*dvec)/ry).^ny).^(1/ny) + ky*dvec;
%     R2 = (kb-kp)*(dvec-dbr)./(1+abs(((kb-kp).*(dvec-dbr))/rb).^nb).^(1/nb) + kp*(dvec-dbr);
%     [do,~] = intersections(dvec,R1,dvec,R2,0);
%     if length(do)>1; do = do(1); end %Handles possibility of more than one intersection
%     if isempty(do); do = do_temp; end %Handles possibility of no intersections
%Richard Equation:
    R(d<=dbr) = (ki-ky)*d(d<=dbr)./(1+abs(((ki-ky).*d(d<=dbr))/ry).^ny).^(1/ny) + ky*d(d<=dbr);
    Rval = (ki-ky)*dbr./(1+abs(((ki-ky).*dbr)/ry).^ny).^(1/ny) + ky*dbr;
    R(d>dbr) = Rval + (kb-kp)*(d(d>dbr)-dbr)./(1+abs(((kb-kp).*(d(d>dbr)-dbr))/rb).^nb).^(1/nb) + kp*(d(d>dbr)-dbr);
%Functional:
    f = trapz(d,abs(P-R')); %transpose needed because P is a column vector, and R is a row vector
