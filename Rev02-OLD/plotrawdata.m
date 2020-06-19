function plotrawdata(rawdata,visualize)

if visualize
    
%Extracts Field Names:
    alltest = fieldnames(rawdata);
%Plots Raw Data:
    for itest = 1:size(alltest,1)
        figure('name',alltest{itest});
        subplot(2,2,1); plot(rawdata.(alltest{itest}).t);
                        xlabel('step'); ylabel('time'); grid on;
        subplot(2,2,2); plot(rawdata.(alltest{itest}).e);
                        xlabel('step'); ylabel('strain'); grid on;
        subplot(2,2,3:4); plot(rawdata.(alltest{itest}).d,rawdata.(alltest{itest}).P);
                          xlabel('displacement (mm)'); ylabel('load (kN)'); grid on;
    end
    
end