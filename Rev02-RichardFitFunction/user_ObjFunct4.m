function f = user_ObjFunct4(x,e,s)

%Unpacks Parameters
    Ei = x(1); Ep = x(2); sy = x(3); ny = x(4);
%Richard Equation:
    R = (Ei-Ep)*e./(1+abs(((Ei-Ep).*e)/sy).^ny).^(1/ny) + Ep*e;
%Functional:
    f = trapz(e,abs(s-R));
