function f = user_ObjFunct9(x,e,s)

%Unpacks Parameters
    Ei = x(1); Ep = x(2); sy = x(3); ny = x(4); ebr = x(5);
    Eb = x(6); Ed = x(7); sb = x(8); nb = x(9);
%Richard Equation:
    %Initializes Nine-Parameter Richard Equation Fit:
        R = zeros(size(e));
    %Constructs Nine-Parameter Richard Equation Fit:
        R(e<=ebr) = (Ei-Ep)*e(e<=ebr)./(1+abs(((Ei-Ep).*e(e<=ebr))/sy).^ny).^(1/ny) + Ep*e(e<=ebr);
        Rval = (Ei-Ep)*ebr./(1+abs(((Ei-Ep).*ebr)/sy).^ny).^(1/ny) + Ep*ebr;
        R(e>ebr) = Rval + (Eb-Ed)*(e(e>ebr)-ebr)./(1+abs(((Eb-Ed).*(e(e>ebr)-ebr))/sb).^nb).^(1/nb) + Ed*(e(e>ebr)-ebr);
%Functional:
    f = trapz(e,abs(s-R));
