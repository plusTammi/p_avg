classdef Paths
    %PATHS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        case_id
        
        %types={'raw','cur','qrs_avgs','avgs_start','p_avgs',...
        %    'qrs_triggers','p_triggers','bad_chn','borders'};
        types={'raw','mat'};
        empty_paths={{''},{''}};
        paths

    end
    
    methods
        function obj = Paths(path)
            obj.paths=containers.Map(obj.types,obj.empty_paths);
            if exist(path)~=7
                error('%s does not exist',path)
            end
            files=ReadFiles(path,{'fif'});
            sort(files)
        	obj.paths('raw')=files;
            files= ReadFiles(path,{'mat'});
            if size(files,1)~=size(obj.paths('raw'),1)
                files=obj.paths('raw');
                for i=1:size(files,1)
                    files(i)=strrep(files(i),'fif','mat');
                end
            end
            obj.paths('mat')=files;
            
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