classdef Data < handle
    %This class is where the data will be stored, and it handles loading
    %and saving of the data
    
    properties 
        
        paths           %A path for every variable where it can be saved
        path_mat        %A path for mat file, which contains variable map, 
                        %which contains the sizes of the variables
        path_fif        %A path for the raw data
        
        save_types      %List for the numerical types in which the variables are to be saved
        values          %Map which will contain data of all variables, key will be in variables list
        sizes           %Map which contains the sizes of variables
        
        %To add new variable, add it's name to varables list, the numerical
        %type in witch you want to save it in var_type list, and the
        %numerical type in witch you want to load it to calc_type
        variables={'raw','cur','qrs_avgs','avg_start','p_avgs',... 
        'qrs_triggers','p_triggers','bad_chn','projs','borders',...
        'len_chn_trigs','good_beats'}
        var_type={'single','single','double','double','double','double',...
            'double','int32','double','double','double','double'}
        calc_type={'double','double','double','double','double','double',...
            'double','double','double','double','double','double'}
    end
    
    methods
        function obj = Data(path)
            %path argument is a file name to the raw fif file.
            if exist(path,'file')==0                %Make sure the fif file exist
                error('%s does not exist',path);
            end
            
            %Make the save names for variables. File names will be the same
            %as fif file, mut where the .fif is replaced with
            %_variable_name.bin
            paths=cell(length(obj.variables),1);
            for i=1:length(obj.variables)
                paths{i}=strrep(path,'.fif',strcat('_',obj.variables{i},'.bin'));
            end
            
            %The mat file containing sizes will be the same as raw file,
            %but .fif replaced with .mat
            path_mat=strrep(path,'.fif','.mat');
            %Initialaising path variables
            obj.path_fif=path;
            obj.paths=containers.Map(obj.variables,paths);
            obj.path_mat=path_mat;
            
            %If the file containing sizes doesn't exist, it will be made
            %here
            if exist(obj.path_mat,'file')==0
                map=containers.Map();
                save(obj.path_mat,'map');
            end
            %If the file existed, but didn't contain variable map, it will
            %be made here
            warning('off','MATLAB:load:variableNotFound')
            load(obj.path_mat,'map');
            warning('on','MATLAB:load:variableNotFound')
            if exist('map','var')==0
                map=containers.Map();
                save(obj.path_mat,'map','-append');
            end
            %Initialaising other variables
            obj.save_types=containers.Map(obj.variables,obj.var_type);
            obj.values=containers.Map();
            obj.sizes=containers.Map();
            
            
        end
        
        function bool=load_raw(obj)
            %Load raw files from fif
            r=fiff_setup_read_raw(obj.path_fif);
            obj.values('raw')=fiff_read_raw_segment(r);
            obj.sizes('raw')=size(obj.values('raw'));
            bool=true;
        end
        
        function load_projs(obj)
            %Load ssp projections
            [fid,tree,~]=fiff_open(obj.path_fif);
            obj.values('projs')=fiff_read_proj(fid,tree);
        end
        
        function bool=is_loaded(obj,variables,err)
            %Check if the variable names in variables are loaded. Return
            %true if variables are loaded. If err=true, this function will 
            %throw error if variable is not loaded, otherwise it will 
            %return false
            if nargin<3
                err=true;
            end
            bool=true;
            not_loaded=variables(~obj.values.isKey(variables));
            if size(not_loaded,2)~=0
                if err
                    fprintf('Variables not loaded:')
                    for i=not_loaded
                        fprintf(' %s,',char(i))
                    end
                    fprintf('\n')
                    error(char(not_loaded),'Not loaded')
                end
                bool=false;
            end
                    
        end
        
        function load(obj,variables,force_load)
            %Variables is cell array containing variables to be loaded. If
            %not given, all variables will be loaded. If force_load is
            %true, variables will be loaded from file even if they are
            %already loaded.
            %If variable is not saved, will print the name of the variable
            %not loaded and continue.
            if nargin<2
                variables=obj.variables;
            end
            if nargin<3
                force_load=false;
            end

            if ~force_load
                variables=variables(~obj.values.isKey(variables));
            end
            for i=variables
                i=char(i);
                switch char(i)
                    %fif files needs different loading fucntions
                    case 'fif'
                        obj.load_raw()
                    case 'raw'
                        %If there is raw file saved as binary file, it will
                        %be loaded, otherwise fif.
                        if exist(obj.paths(i),'file')
                            obj.load_data(i)
                        else
                            obj.load_raw()
                        end
                    case 'projs'
                        if exist(obj.paths(i),'file')
                            obj.load_data(i)
                        else
                            obj.load_projs()
                        end
                    otherwise
                        obj.load_data(i)
                        
                end
            end
        end            
        
        
        
        function save(obj,variables)
            %Variables is cell array containing variables to be saved. If
            %not given, all will be saved. Currently ssp projections are not
            %saved.
            if nargin<2
                variables=obj.variables;
            end

            variables=variables(obj.values.isKey(variables));
            load(obj.path_mat,'map');
            obj.sizes=map;
            for i=variables
                i=char(i);
                %Skip ssp projections
                if strcmp(i,'projs')
                    continue %Temporary
                end
                fileID = fopen(obj.paths(i),'w');
                fwrite(fileID,obj.values(i),obj.save_types(i));
                fclose(fileID);
                obj.sizes(i)=size(obj.values(i));
                map=obj.sizes;
                save(obj.path_mat,'map');
                
            end
        end
        
        function remove(obj,variables)
            %Deletes all binary files and mat files that this class has
            %made.
            if nargin<2
                variables=obj.variables;
                variables{end+1}='mat'
            end
            for i=variables
                if strcmp(char(i),'mat')
                    delete(obj.path_mat)
                else
                    delete(obj.paths(char(i)))
                end
                
            end
        end
        
    end
    
	methods (Access = 'private', Hidden=true)
        function load_data(obj,var)
            %Load function, which loads variable given, or prints its path
            %if it is not saved.
            var=char(var);
            if exist(obj.paths(char(var)),'file')==2
                fileID = fopen(obj.paths(var));
                obj.values(var)=fread(fileID,obj.save_types(var));
                fclose(fileID);
                load(obj.path_mat,'map');
                obj.sizes=map;
                if size(obj.values(var),1)==0
                    obj.values(var)=obj.values(var);
                else
                    obj.values(var)=double(reshape(obj.values(var),map(var)));
                end
            else
                fprintf('file does not exist %s \n',obj.paths(var))
            end
            
        end
        

        
    end
            
    methods (Access = 'public', Hidden=true)
        %These methods overload dot notation, so you can acces variable mat
        %with obj.variable notation.
        function varargout = subsref(obj, subStruct)
            
            if subStruct(1).type=='.'
                if isKey(obj.values,subStruct(1).subs)
                    if length(subStruct)==1
                        [varargout{1:nargout}]=obj.values(subStruct(1).subs);
                    else
                        [varargout{1:nargout}]= builtin('subsref',obj.values(subStruct(1).subs),subStruct(2:end));
                    end
                else
                    [varargout{1:nargout}]=builtin('subsref',obj,subStruct);
                end
            else
                [varargout{1:nargout}]=builtin('subsref',obj,subStruct);
            end
        end

        function obj=subsasgn(obj, subStruct,B)
            if subStruct(1).type=='.'
                if isKey(obj.values,subStruct(1).subs)
                    if length(subStruct)>1
                        obj.values(subStruct(1).subs)=builtin('subsasgn',obj.values(subStruct(1).subs),subStruct(2:end),B);
                    else
                        obj.values(subStruct(1).subs)=B;
                    end
                elseif isKey(obj.save_types,subStruct(1).subs)
                    obj.values(subStruct(1).subs)=B;
                else
                    obj=builtin('subsasgn',obj,subStruct,B);
                end
            else
                obj=builtin('subsasgn',obj,subStruct,B);
            end
        end
        
        function names=properties(obj)
            names=[fieldnames(obj)',obj.variables];
        end
    end
end

