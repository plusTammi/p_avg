
classdef Preprocess
    %PREPROCESS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        d
    end
    
    properties (Constant)
        fs=1000
    end
    
    methods
        function obj=Preprocess(path)
            obj.d=Data(path);
        end
        
        function qrs_trig(obj)
            [triggers,len_chn_trigs]=qrs_triggering(obj.d.cur,obj.fs);
            obj.d.qrs_triggers=int32(triggers);
            obj.d.len_chn_trigs=int32(len_chn_trigs);
        end
        
        function compute_bad_chn(obj)
            obj.d.bad_chn=find_bad_chn(obj.d.cur,obj.d.len_chn_trigs);
        end
        
        function compute_ssp(obj)
            mags=1:3:99;
            grads=setdiff(1:99,mags);
            obj.d.load_projs(obj.d.cur_meas);
            %size(obj.d.raw(grads(obj.d.bad_chn),:))
            mag_bads=obj.d.bad_chn(mags);
            grad_bads=obj.d.bad_chn(grads);
            
            g=obj.d.raw(grads(~grad_bads),:);
            m=obj.d.raw(mags(~mag_bads),:);
            [ssp_grads,ssp_mags]=ssp(g,m,obj.d.projs,grads(~grad_bads),mags(~mag_bads));
            obj.d.cur(grads(~grad_bads),:)=ssp_grads
            obj.d.cur(mags(~mag_bads),:)=ssp_mags
        end
        
        function compute_baseline(obj)
            bl=baseline(obj.d.cur,obj.d.qrs_triggers,-400);
            obj.d.cur=obj.d.cur-bl;
        end
        
        
        function compute_averages(obj,avg_start,avg_end)
            if nargin<3
                avg_start=-500;
                avg_end=500;
            end
            obj.d.qrs_avgs=average(obj.d.cur,obj.d.qrs_triggers,avg_start,avg_end);
            obj.d.avg_start=avg_start
        end
        
        function compute_borders(obj)
            obj.d.borders=borders(obj.d.qrs_avgs)
        end
        
        function p_trig(obj)           
            obj.d.p_triggers=p_trig(obj.d.cur(~obj.d.bad_chn),obj.d.qrs_triggers,obj.d.borders);
        end
        
        function compute_p_averages(obj)
            p_start=obj.d.borders(1);
            p_end=obj.d.borders(2);

            obj.d.p_avgs=average(obj.d.cur,obj.d.qrs_triggers,p_start,p_end);
        end
        
    end
    
end

