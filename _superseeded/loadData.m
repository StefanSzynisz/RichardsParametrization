function rawdata = loadData(tog)
%Loads Raw Data:

if tog.reload
    %--------------------------------------------------------------------------
    %Defines File Path and List of Folders in that Path:
        fpath = '..\..\Experimental-Metallic-Foams\0-Raw Data - MTS Machine\Data_MTS\allData';
        folderList = ls(fpath);
    %Destroys Spaces at the end of folder_list names:
        for ifile = 1:size(folderList,1)
            %Finds Locations of All Non-Space Characters:
                nonspaces = ~isspace(folderList(ifile,:));
            %Locates Index of Last Non-Space Character:
                ind = find(nonspaces,1,'last');
            %Defines Updated Folder List:
                upFolderList(ifile) = string(folderList(ifile,1:ind));
        end

    %Defines File Delimiter and Starting Row:
        delimiter = '\t'; startRow = 6;
    %Initializes Variable rawdata:
        tempdata = [];
    %Loads Data from Files:
        for ifile = 3:size(folderList,1)
            %Defines format string:
                formatSpec = '%s%s%s%s%s%s%s%s%s%s%[^\n\r]';
            %Defines File Name:
                tempstr = upFolderList(ifile);
                fname = sprintf('%s\\%s\\specimen.dat',fpath,tempstr);
            %Opens File:
                fileID = fopen(fname,'r');
            %Read columns of data according to the format.
            % This call is based on the structure of the file used to generate this
            % code. If an error occurs for a different file, try regenerating the code
            % from the Import Tool.
                dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,...
                    'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
            %Defines Variable Name (as updated version of file name):
                tempstr = regexprep(tempstr, ' ', '_');
            %Assigns Data to Structure:
                tempdata.(tempstr) = dataArray;
            %Closes File:
                fclose(fileID);
        end
    %--------------------------------------------------------------------------

    %Updates Variable Names:
        replacementstrs = {'Luiz','Aco','Al',' ';
                           '','SF_T','AF_T','_'};
        oldVarNames = strrep(upFolderList(3:end),' ','_'); %Replaces Portions of Old Variable Names
        newVarNames = oldVarNames;                         %Initializes New Variable Names
    %Defines New Variable Names:
        for istr = 1:size(replacementstrs,2)
            newVarNames = strrep(newVarNames,replacementstrs{1,istr},replacementstrs{2,istr});
        end
    %Assigns Data to rawdata Structure:
        for ifile = 1:length(fieldnames(tempdata))
            temp_time   = tempdata.(oldVarNames{ifile})(:,1); rawdata.(newVarNames{ifile}).t     = str2double(temp_time{:});    %Time:
            temp_disp   = tempdata.(oldVarNames{ifile})(:,2); rawdata.(newVarNames{ifile}).d     = -str2double(temp_disp{:});   %Displacement
            temp_strain = tempdata.(oldVarNames{ifile})(:,3); rawdata.(newVarNames{ifile}).e_ext = -str2double(temp_strain{:}); %Measured Axial Strain (with extensometer)
            temp_load   = tempdata.(oldVarNames{ifile})(:,4); rawdata.(newVarNames{ifile}).P     = -str2double(temp_load{:});   %Axial Load
        end
                        
    %Overwrites Data for SF_T24C:
        tempdata = xlsread('..\..\Experimental-Metallic-Foams\1-Excel\Steel-13-10-2016.xlsx','Steel_24_inf','B21:E3021');
        rawdata.SF_T24C.t     = tempdata(:,1);  %seconds
        rawdata.SF_T24C.d     = -tempdata(:,2); %mm
        rawdata.SF_T24C.e_ext = -tempdata(:,3); %strain
        rawdata.SF_T24C.P     = -tempdata(:,4); %Newtons
    %Consolidates Data from SF_T150C_15, which was taken in two parts:
        rawdata.SF_T150C_15.t     = [rawdata.SF_T150C_15_Part_I.t;rawdata.SF_T150C_15_Part_I.t(end)+rawdata.SF_T150C_15_Part_II.t]; %seconds
        rawdata.SF_T150C_15.d     = [rawdata.SF_T150C_15_Part_I.d;rawdata.SF_T150C_15_Part_II.d];                                   %mm
        rawdata.SF_T150C_15.e_ext = [rawdata.SF_T150C_15_Part_I.e_ext;rawdata.SF_T150C_15_Part_II.e_ext];                           %strain
        rawdata.SF_T150C_15.P     = [rawdata.SF_T150C_15_Part_I.P;rawdata.SF_T150C_15_Part_II.P];                                   %Newtons
    %Deletes two SF_T150C_15 parts, now that test data has been
    %consolidated:
        rawdata = rmfield(rawdata,'SF_T150C_15_Part_I');
        rawdata = rmfield(rawdata,'SF_T150C_15_Part_II');

    %Defines Specimen Area (Measured, and Designated on Excel Sheet)
        rawdata.SF_T24C.Area          = 476.58;
        rawdata.SF_T150C_15.Area      = 468.23;
        rawdata.SF_T150C_30.Area      = 489.57;
        rawdata.SF_T200C_15.Area      = 475.29;
        rawdata.SF_T200C_30.Area      = 498.76;
        rawdata.SF_T300C_15.Area      = 471.44;
        rawdata.SF_T300C_30.Area      = 483.70;
        rawdata.SF_T400C_15_cp11.Area = 494.15;
        rawdata.SF_T400C_30_cp12.Area = 472.72;
        rawdata.SF_T700C_15.Area      = 489.57;
        rawdata.SF_T300C_15_cp9.Area  = 456.17;
        rawdata.SF_T300C_30_cp10.Area = 454.91;
        rawdata.SF_T550C_15.Area      = 471.44;
        
        rawdata.AF_T24C.Area          = 486.95;
        rawdata.AF_T150C_15.Area      = 474.65;
        rawdata.AF_T150C_30.Area      = 484.35;
        rawdata.AF_T200C_15.Area      = 482.40;
        rawdata.AF_T200C_30.Area      = 470.79;
        rawdata.AF_T300C_15.Area      = 482.40;
        rawdata.AF_T300C_30.Area      = 467.59;
        rawdata.AF_T500C_15.Area      = 470.15;
        
        
    %Error Handling -- Processes raw data, removes nan entries and starts
    %data at zero:
        %Extracts Updated Data Fields:
            datafields = fieldnames(rawdata);    
            nspec = length(datafields);
        %Removes nan entries and starts data at zero:
            for ispec = 1:nspec
                %Locates indices of nan values:
                    ind_nan = find(isnan(rawdata.(datafields{ispec}).t));
                %Removes Located Indices:
                    rawdata.(datafields{ispec}).t(ind_nan)     = [];
                    rawdata.(datafields{ispec}).d(ind_nan)     = [];
                    rawdata.(datafields{ispec}).e_ext(ind_nan) = [];
                    rawdata.(datafields{ispec}).P(ind_nan)     = [];
%                 %Starts data at zero value:
%                     rawdata.(datafields{ispec}).t     = [0;rawdata.(datafields{ispec}).t];
%                     rawdata.(datafields{ispec}).d     = [0;rawdata.(datafields{ispec}).d];
%                     rawdata.(datafields{ispec}).e_ext = [0;rawdata.(datafields{ispec}).e_ext];
%                     rawdata.(datafields{ispec}).P     = [0;rawdata.(datafields{ispec}).P];
                %Adds stress and strain fields to data structure:
                    rawdata.(datafields{ispec}).e = rawdata.(datafields{ispec}).d./50;
                    rawdata.(datafields{ispec}).s = rawdata.(datafields{ispec}).P./rawdata.(datafields{ispec}).Area;
%                     figure; plot(rawdata.(datafields{ispec}).d,rawdata.(datafields{ispec}).P);
%                     figure; plot(rawdata.(datafields{ispec}).e,rawdata.(datafields{ispec}).s);
            end
        
    %Saves Data:
        save('RawData.mat','rawdata');
else
    %Loads Data from Preexisting .mat file
        load('RawData.mat');
end
    
    