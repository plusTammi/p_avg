
classdef Preprocess
    %Yhdistää kaikki muut luokat. Tämän funktion kautta kutsutaan kaikki
    %funktiot, jotka tekevät sitten halutun toiminnon. Funktioden on
    %tarkoitus olla melko suppeita ja ainoastaan tarjota data muille
    %funktiolle oikeassa muodossa.
    
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
            obj.is_loaded({'cur'});
            [triggers,len_chn_trigs]=qrs_triggering(obj.d.cur,obj.fs);
            obj.d.qrs_triggers=int32(triggers);
            obj.d.len_chn_trigs=int32(len_chn_trigs);
        end
        
        function compute_bad_chn(obj)
            obj.is_loaded({'cur','len_chn_trigs'});
            obj.d.bad_chn=find_bad_chn(obj.d.cur,obj.d.len_chn_trigs);
        end
        
        function compute_ssp(obj)
            obj.is_loaded({'raw','bad_chn'});
            mags=1:3:99;
            grads=setdiff(1:99,mags);
            obj.d.load_projs();
            %size(obj.d.raw(grads(obj.d.bad_chn),:))
            mag_bads=obj.d.bad_chn(mags);
            grad_bads=obj.d.bad_chn(grads);
            
            g=obj.d.raw(grads(~grad_bads),:);
            m=obj.d.raw(mags(~mag_bads),:);
            [ssp_grads,ssp_mags]=ssp(g,m,obj.d.projs,grads(~grad_bads),mags(~mag_bads));
            obj.d.cur(grads(~grad_bads),:)=ssp_grads;
            obj.d.cur(mags(~mag_bads),:)=ssp_mags;
        end
        
        function compute_baseline_spline(obj,point)
            obj.is_loaded({'cur','qrs_triggers'});
            if nargin<2
                point=-400;
            end
            bl=baseline_spline(obj.d.cur,obj.d.qrs_triggers,point);
            obj.d.cur=obj.d.cur-bl;
        end
        
        function compute_baseline_lsqspline(obj)
            obj.is_loaded({'cur','qrs_triggers','borders'});
            bl=baseline_lsqspline(obj.d.cur,obj.d.qrs_triggers,obj.d.borders);
            obj.d.cur=obj.d.cur-bl;
        end
        
        function compute_averages(obj,avg_start,avg_end,corr)
            if nargin<4
                corr=0
            end
            obj.is_loaded({'cur','qrs_triggers'});
            if nargin<3
                avg_start=-500;
                avg_end=500;
            end
            obj.d.qrs_avgs=average(obj.d.cur(obj.good_chn,:),obj.d.qrs_triggers,avg_start,avg_end,corr);
            obj.d.avg_start=avg_start
        end
        
        function compute_borders(obj)
            obj.is_loaded({'qrs_avgs'});
            obj.d.borders=borders(obj.d.qrs_avgs);
        end
        
        function p_trig(obj)  
            obj.is_loaded({'bad_chn','qrs_triggers','borders'});
            obj.d.p_triggers=p_trig(obj.d.cur(~obj.d.bad_chn,:),obj.d.qrs_triggers,obj.d.borders);
            
        end
        
        function compute_p_averages(obj,corr)
            obj.is_loaded({'borders','cur','qrs_triggers','p_triggers'});
            p_start=-300;
            p_end=obj.d.borders(2);
            unique(obj.d.p_triggers(3,:))
            chns=obj.good_chn();
            obj.d.p_avgs=average(obj.d.cur(chns(unique(obj.d.p_triggers(3,:))),:),int32(obj.d.qrs_triggers)+int32(obj.d.p_triggers(1,:)),p_start,p_end,corr);
        end
        
    end
    
	methods 
        
        function bool=is_loaded(obj,variables,err)
            if nargin<3
                err=true;
            end
            bool=obj.d.is_loaded(variables,err);
        end
        
        function good=good_chn(obj,chn)
            if nargin<2
                chn=1:123;
            end
            goods=~obj.d.bad_chn;
            goods=goods(chn);
            good=chn(goods);
        end
    end

    
end

