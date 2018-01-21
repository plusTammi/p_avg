
classdef Preprocess
    %Class, which contains the data and preprocessing functions.
    
    properties
        data %Data class, takes care of the data
    end
    
    properties (Constant)
        fs=1000
    end
    
    methods
        function obj=Preprocess(path)
            %Initialaise property data with Data class
            obj.data=Data(path);
        end
        
        function qrs_trig(obj)
            %QRS_triggering
            %Needs only current data to be loaded. Saves trigger points and
            %number of beats found on each channel.
            obj.is_loaded({'cur'});
            [triggers,len_chn_trigs]=qrs_triggering(obj.data.cur,obj.fs);
            obj.data.qrs_triggers=int32(triggers);
            obj.data.len_chn_trigs=int32(len_chn_trigs);
        end
        
        function find_bad_chn(obj)
            %Finds bad channels
            obj.is_loaded({'cur','len_chn_trigs'});
            obj.data.bad_chn=find_bad_chn(obj.data.cur,obj.data.len_chn_trigs);
        end
        
        function compute_ssp(obj)
            %Loads ssp projectors, applys them to the raw data and replaces
            %current data with the results
            obj.is_loaded({'raw','bad_chn'});
            mags=1:3:99;
            grads=setdiff(1:99,mags);
            obj.data.load_projs();
            %size(obj.data.raw(grads(obj.data.bad_chn),:))
            mag_bads=obj.data.bad_chn(mags);
            grad_bads=obj.data.bad_chn(grads);
            
            g=obj.data.raw(grads(~grad_bads),:);
            m=obj.data.raw(mags(~mag_bads),:);
            [ssp_grads,ssp_mags]=ssp(g,m,obj.data.projs,grads(~grad_bads),mags(~mag_bads));
            obj.data.cur(grads(~grad_bads),:)=ssp_grads;
            obj.data.cur(mags(~mag_bads),:)=ssp_mags;
        end
        
        function compute_baseline_spline(obj,point)
            %Computes baseline with spline in fixed positions and removes
            %it from the current data
            obj.is_loaded({'cur','qrs_triggers'});
            if nargin<2
                point=-round(diff(obj.data.qrs_triggers)/3);
                point=[-200,point];
            end
            bl=baseline_spline(obj.data.cur,obj.data.qrs_triggers,point);
            obj.data.cur=obj.data.cur-bl;
        end
        
        function compute_baseline_lsqspline(obj)
            %Computes baseline with spline fitted in between T end and P start and removes
            %it from the current data
            obj.is_loaded({'cur','qrs_triggers','borders'});
            bl=baseline_lsqspline(obj.data.cur,double(obj.data.qrs_triggers),double(obj.data.borders));
            obj.data.cur=obj.data.cur-bl;
        end
        
        function compute_averages(obj,avg_start,avg_end)
            %Computes the averages based on qrs triggers
            obj.is_loaded({'cur','qrs_triggers','good_beats'});
            if nargin<3
                avg_start=-500;
                avg_end=500;
            end
            obj.data.qrs_avgs=average(obj.data.cur,obj.data.qrs_triggers(obj.data.good_beats==1),avg_start,avg_end);
            obj.data.avg_start=avg_start;
        end
        
        function compute_borders(obj)
            %Computes borders based on qrs data, not yet implemented
            obj.is_loaded({'qrs_avgs'});
            obj.data.borders=borders(obj.data.qrs_avgs);
        end
        
        function p_trig(obj)
            %Finds P-waves based on borders with correlation
            obj.is_loaded({'cur','bad_chn','qrs_triggers','borders'});
            trigs=double(obj.data.qrs_triggers);
            
            p_triggers=p_trig(obj.data.cur(obj.good_chn(),:),trigs,obj.data.borders);
            chn=obj.good_chn();
            %chn(unique(p_triggers(3,:)))
            %obj.data.p_triggers=trigs+p_triggers(1,:)+round((obj.data.borders(1)+obj.data.borders(2))/2);
            obj.data.p_triggers=p_triggers;
            
        end
        
        
        function find_good_beats(obj,triggers,start,ending,treshold,chns)
            %Finds good beats. Computes correlation between beats in
            %triggers. Start and ending define the beat borders and
            %treshold is the cut of correlation to hierarchial clustering
            obj.is_loaded({'bad_chn','cur'});
            if nargin<3
                start=-300;
                ending=300;
            end
            if nargin<5
                treshold=0;
            end
            if nargin<6
                chns=obj.good_chn();
            end
            
            obj.data.good_beats=good_beats(obj.data.cur(chns,:),triggers,start,ending,treshold);
        end
        
        function compute_p_averages(obj,trigs)
            %Computes averages based on P triggers and p borders.
            obj.is_loaded({'borders','cur','qrs_triggers','p_triggers'});
            p_rad=round((obj.data.borders(2)-obj.data.borders(1))/2);
            p_start=obj.data.borders(1)-100;
            p_end=500;
            %trigs=obj.data.p_triggers;
            obj.data.p_avgs=average(obj.data.cur,trigs,p_start,p_end);
        end
        
    end
    
	methods 
        
        function bool=is_loaded(obj,variables,err)
            %Checks if variable is loaded
            if nargin<3
                err=true;
            end
            bool=obj.data.is_loaded(variables,err);
        end
        
        function good=good_chn(obj,chn)
            if nargin<2
                s=obj.data.sizes('raw');
                chn=1:s(1);
            end
            goods=~obj.data.bad_chn;
            goods=goods(chn);
            good=chn(goods);
        end
    end

    
end

