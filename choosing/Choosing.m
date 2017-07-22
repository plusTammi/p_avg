classdef Choosing < handle
    %CHOOSING Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        paths
        qrs_avgs
        borders
        avg_start
    end
    
    methods
        function obj=Choosing(paths)
            if ischar(paths)
                paths={paths};
            end
            obj.paths=paths;
        end
        
        function load_qrs_avgs(obj)
            obj.qrs_avgs=cell(length(obj.paths),1);
            mags=1:3:99;
            grads=setdiff(1:99,mags);
            obj.borders=cell(length(obj.paths),0);
            obj.avg_start=cell(length(obj.paths),0);
            for i=1:length(obj.paths)
                i
                p=Preprocess(char(obj.paths(i)));
                p.d.load({'qrs_avgs','borders','avg_start','bad_chn'});
                chns=p.good_chn();
                mags=p.good_chn(1:3:99);
                grads=p.good_chn(setdiff(1:3:99,mags));
                ecg=p.good_chn(109:123);
                avgs=p.d.qrs_avgs;
                avgs(mags,:)=avgs(mags,:)/max(max(abs(avgs(mags,:))));
                avgs(grads,:)=avgs(grads,:)/max(max(abs(avgs(grads,:))));
                avgs(ecg,:)=avgs(ecg,:)/max(max(abs(avgs(ecg,:))));
                %avgs=p.d.qrs_avgs(p.good_chn,:);
                if ~p.d.is_loaded({'borders'},false)
                    obj.borders{i}=zeros(5,1);
                else
                    obj.borders{i}=p.d.borders-p.d.avg_start;
                end
                obj.qrs_avgs{i}=avgs;
                obj.avg_start{i}=p.d.avg_start;
            end
        end
        
        function choose(obj)
            cur=1;
            cur_before=0;
            button=0;
            length(obj.qrs_avgs)
            while(button~=27)%esc==27
                if cur~=cur_before
                    cur_before=cur
                    clf();
                    hold on
                    plot(obj.qrs_avgs{cur}(1:3:99+2,:)','r');
                    points=plot(obj.borders{cur},zeros(size(obj.borders{cur})),'.');
                end
                [x,~,button]=ginput(1);
                if button==100
                    if cur<length(obj.qrs_avgs)
                        cur=cur+1;
                    else
                        display('last one')
                    end
                end
                if button==97
                    if cur>1
                        cur=cur-1;
                    else
                        display('first one')
                    end
                end
                if button==115
                    bords=zeros(length(obj.borders{cur}),1);
                    points.XData=bords;
                    obj.borders{cur}=bords;
                    refreshdata
                    points.XData
                end
                if button==1
                    if any(obj.borders{cur}==0)
                        index=find(obj.borders{cur}==0,1,'first');
                        points.XData(index)=round(x);
                        obj.borders{cur}(index)=round(x);
                    else
                        bords=points.XData-x;
                        [~,index]=min(abs(bords));
                        points.XData(index)=round(x);
                        obj.borders{cur}(index)=round(x);
                    end
                    refreshdata
                end
            end
            close
        end
        
        function save_borders(obj)
            for i=1:length(obj.paths)
                i
                p=Preprocess(char(obj.paths(i)));
                p.d.borders=obj.borders{i}+obj.avg_start{i};
                p.d.save({'borders'});
            end
        end
    end
    
end



%paths={'/media/ju/New Volume/Secreto/case_1771','/media/ju/New Volume/Secreto/case_1696','/media/ju/New Volume/Secreto/case_1698'}
