classdef Data < handle
    %Pitää sisällään kaiken data, hoitaa sen lataamisen ja tallentamisen.
    %Jos haluaa lisätä uusia datoja, niin lisää properties kohtaan vaan
    %muuttujan, sekä variables listaan sen nimen. var_type ei tällä
    %hetkellä käytössä. Ainoastaan ssp-vektoreille oma lataus funktio.
    
    properties 
        raw
        cur
        qrs_avgs
        avg_start
        p_avgs
        qrs_triggers
        p_triggers
        bad_chn
        projs
        borders
        paths
        len_chn_trigs
        
        cur_meas='m1'
        variables={'raw','cur','qrs_avgs','avg_start','p_avgs',...
        'qrs_triggers','p_triggers','bad_chn','projs','borders','len_chn_trigs'}
        var_type={'single','single','double','int32','double','int32',...
            'int32','int16','double','int32','int32'}
    end
    
    methods
        function obj = Data(path)
            obj.paths=Paths(path);
            ones(length(obj.variables),0)
            size(obj.variables)
        end
        
        function load_raw(obj,measurement)
            r=fiff_setup_read_raw(obj.paths.get_path('raw',measurement));
            obj.raw=fiff_read_raw_segment(r);
            obj.raw=obj.raw
        end
        
        function load_projs(obj,measurement)
            [fid,tree,~]=fiff_open(obj.paths.get_path('raw',measurement));
            obj.projs=fiff_read_proj(fid,tree);
        end
        
        function load(obj,variables,measurement,force_load)
            if nargin<2
                variables=obj.variables;
            end
            if nargin<3
                measurement=obj.cur_meas;
            else 
                obj.cur_meas=measurement;
            end
            if nargin<4
                force_load=false;
            end
                
            path=obj.paths.get_path('mat',measurement);
            if exist(path,'file')==0
                obj.save();
            end
            mask=zeros(size(variables));
            for i=1:size(variables,2)
                strcat('obj.',char(variables(i)));
                if size(eval(strcat('obj.',char(variables(i)))))==0
                    mask(i)=1;
                end
            end
            if ~force_load
                variables=variables(mask==1);
            end
            if ~isempty(variables)
                load(path,variables{:});
            end
            
            for i=1:length(variables)
                temp1=char(strcat('obj.',variables(i)));
                temp2=char(variables(i));
                temp=strcat(temp1,'=',temp2,';');
                eval(temp);
            end
            if ~isempty(variables)
                temp=strfind([variables{:}],'raw');
            else
                temp=[];
            end
            if ~isempty(temp) && isempty(obj.raw)
                obj.load_raw(measurement);
            end
            if ~isa(class(obj.cur),'double')
                obj.cur=double(obj.cur);
            end
            
            if ~isa(class(obj.raw),'double')
                obj.raw=double(obj.raw);
            end
            
        end
        
        
        
        function save(obj,variables)
            if nargin<2
                variables=obj.variables;
            end
            raw=[];
            cur=[];
            path=obj.paths.get_path('mat',obj.cur_meas);
            for i=1:length(variables)
                temp1=char(strcat('obj.',variables(i)));
                temp2=char(variables(i));
                temp=strcat(temp2,'=',temp1,';');
                eval(temp);
            end
            raw=single(raw); 
            cur=single(cur);
            save(path,variables{:},'-append');
        end
    end
    
end

