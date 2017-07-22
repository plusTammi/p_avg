classdef Data < handle
    %Pitää sisällään kaiken data, hoitaa sen lataamisen ja tallentamisen.
    %Jos haluaa lisätä uusia datoja, niin lisää properties kohtaan vaan
    %muuttujan, sekä variables listaan sen nimen. var_type ei tällä
    %hetkellä käytössä. Ainoastaan ssp-vektoreille oma lataus funktio.
    
    properties 
        %raw
        %cur
        %qrs_avgs
        %avg_start
        %p_avgs
        %qrs_triggers
        %p_triggers
        %bad_chn
        %projs
        %borders
        %len_chn_trigs
        
        paths
        path_mat
        path_fif
        
        save_types
        values
        sizes
        
        cur_meas='m1'
        variables={'raw','cur','qrs_avgs','avg_start','p_avgs',...
        'qrs_triggers','p_triggers','bad_chn','projs','borders',...
        'len_chn_trigs','good_beats'}
        var_type={'single','single','double','double','double','double',...
            'double','int32','double','double','double','double'}
        calc_type={'double','double','double','double','double','double',...
            'double','double','double','double','double','int32'}
    end
    
    methods
        function obj = Data(path)
            if exist(path,'file')==0
                error('%s does not exist',path);
            end
            paths=cell(length(obj.variables),1);
            for i=1:length(obj.variables)
                paths{i}=strrep(path,'.fif',strcat('_',obj.variables{i},'.bin'));
                
            end
            path_mat=strrep(path,'.fif','.mat');
            obj.path_fif=path;
            obj.paths=containers.Map(obj.variables,paths);
            obj.path_mat=path_mat;
            
            
            if exist(obj.path_mat,'file')==0
                map=containers.Map();
                save(obj.path_mat,'map');
            end
            warning('off','MATLAB:load:variableNotFound')
            load(obj.path_mat,'map');
            warning('on','MATLAB:load:variableNotFound')
            if exist('map','var')==0
                map=containers.Map();
                save(obj.path_mat,'map','-append');
            end
            obj.save_types=containers.Map(obj.variables,obj.var_type);
            obj.values=containers.Map();
            obj.sizes=containers.Map();
            
            
        end
        
        function bool=load_raw(obj)
            r=fiff_setup_read_raw(obj.path_fif);
            obj.values('raw')=fiff_read_raw_segment(r);
            bool=true;
        end
        
        function load_projs(obj)
            [fid,tree,~]=fiff_open(obj.path_fif);
            obj.values('projs')=fiff_read_proj(fid,tree);
        end
        
        function bool=is_loaded(obj,variables,err)
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
                    case 'fif'
                        obj.load_raw()
                    case 'raw'
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
            if nargin<2
                variables=obj.variables;
            end

            variables=variables(obj.values.isKey(variables));
            load(obj.path_mat,'map');
            obj.sizes=map;
            for i=variables
                i=char(i);
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

