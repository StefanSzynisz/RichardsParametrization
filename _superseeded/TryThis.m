clc; close all;

dvec = 0:0.001:25;

ki = 20; ky = 1; dbr = 0.0; ry = 50.0; ny = 10.0;
R1 = (ki-ky)*(dvec-dbr)./(1+abs(((ki-ky).*(dvec-dbr))/ry).^ny).^(1/ny) + ky*(dvec-dbr);
figure; ax = gca;
plot(dvec,R1,'-.','linewidth',2.5,'color',[0.5,0.5,0.60]); hold all;

%Determines Load at 15.0:
    dval = 15.0;
    R1val = (ki-ky)*(dval-dbr)./(1+abs(((ki-ky).*(dval-dbr))/ry).^ny).^(1/ny) + ky*(dval-dbr);

kb = 1; kp = 10; dbr = 15.0; rb = 50.0; nb = 3.0; Runl = 50.0;
R2 = R1val+(kb-kp)*(dvec-dbr)./(1+abs(((kb-kp).*(dvec-dbr))/rb).^nb).^(1/nb) + kp*(dvec-dbr);
plot(dvec,R2,'-.','linewidth',2.5,'color',[0.60,0.5,0.5]); hold all;

R(dvec<=dbr) = (ki-ky)*(dvec(dvec<=dbr))./(1+abs(((ki-ky).*(dvec(dvec<=dbr)))/ry).^ny).^(1/ny) + ky*(dvec(dvec<=dbr));
R(dvec>dbr) = R1val+(kb-kp)*(dvec(dvec>dbr)-dbr)./(1+abs(((kb-kp).*(dvec(dvec>dbr)-dbr))/rb).^nb).^(1/nb) + kp*(dvec(dvec>dbr)-dbr);
plot(dvec,R,'-','linewidth',1.5,'color',ax.ColorOrder(1,:)); hold all;
grid on; ax.FontSize = 12;
xlabel('Deformation','FontSize',14); ylabel('Load','FontSize',14);

legend('Elastic Construction Curve','Plastic Construction Curve','Combined Curve','location','northwest');
ax.YLim = [0,135];