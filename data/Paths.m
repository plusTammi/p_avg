classdef Paths %turha
    %Etsii annetun kansion alta kaikki fif ja mat tyyppiset tiedostot.
    %Tulevaisuutta ajattelen tämä luokka saatetaan poistaa kokonaan, jos
    %unohdetaan kaikki tiedostoautomaatiot ja oletetaan, että käyttäjä
    %antaa Preprocess luokalle vaan suoraan sen tiedoston, mille lasketaan
    %kaikki.
    %
    
    properties
        case_id
        
        %types={'raw','cur','qrs_avgs','avgs_start','p_avgs',...
        %    'qrs_triggers','p_triggers','bad_chn','borders'};
        %types={'raw','mat'};
        %empty_paths={{''},{''}};
        %paths
        paths

    end
    
    methods
        function obj = Paths(path,variables)
            %obj.paths=containers.Map(obj.types,obj.empty_paths);
            if exist(path,'file')==0
                error('%s does not exist',path)
            end
            paths=cell(length(variables),1);
            for i=length(variables)
                paths{i}=strcat(path,i);
            end
            obj.paths=containers.Map(variables,paths);

            
        end
        
        function path=get_path(obj,type,measurement)
            files=obj.paths(type);
            path=[];
            for i=1:size(files,1)
                if size(findstr(char(files(i)),measurement))~=0
                    path=char(files(i));
                    break
                end
            end
            
        end
        
    end
    
end





function [ FList ] = ReadFiles(DataFolder,extList)
% Author: Thokare Nitin D.
% 
% This function reads all file names contained in Datafolder and it's subfolders
% with extension given in extList variable in this code...
% Note: Keep each extension in extension list with length 3
% i.e. last 3 characters of the filename with extension
% if extension is 2 character length (e.g. MA for mathematica ascii file), use '.'
% (i.e. '.MA' for given example)
% Example:
% extList={'jpg','peg','bmp','tif','iff','png','gif','ppm','pgm','pbm','pmn','xcf'};
% Gives the list of all image files in DataFolder and it's subfolder
% 
DirContents=dir(DataFolder);
FList=[];
NameSeperator='/';
% Here 'peg' is written for .jpeg and 'iff' is written for .tiff
for i=1:numel(DirContents)
    if(~(strcmpi(DirContents(i).name,'.') || strcmpi(DirContents(i).name,'..')))
        if(~DirContents(i).isdir)
            extension=DirContents(i).name(end-2:end);
            if(numel(find(strcmpi(extension,extList)))~=0)
                FList=cat(1,FList,{[DataFolder,NameSeperator,DirContents(i).name]});
            end
        else
            getlist=ReadFiles([DataFolder,NameSeperator,DirContents(i).name],extList);
            FList=cat(1,FList,getlist);
        end
    end
end

end