classdef ownmap 
    properties
        map
        max_idx
    end
    methods
        function obj= ownmap(arg)
            obj.max_idx=arg;
            obj.map=containers.Map('KeyType','double','ValueType','any');

        end;
        function keys=keys(obj)
            keys=obj.map.keys();
        end
    
        function ret=largest_group(obj)
            ret=max(cellfun('size',obj.map.values(),2));
        end
        
        function ret=best_indexes(obj)
            [~,idx]=max(cellfun('size',obj.map.values(),2));
            vals=obj.map.values();
            ret=vals(idx);
        end
        
        function b = subsref(obj, subStruct)
            if subStruct(1).type=='.'
                b=builtin('subsref',obj,subStruct);
            else
                if subStruct(1).subs{1}<=obj.max_idx
                    b=subStruct(1).subs{1};
                else
                    b=obj.map(subStruct(1).subs{1});
                end
            end
        end
        
        function obj=subsasgn(obj, subStruct,B)
            obj.map(subStruct(1).subs{1})=B;
        end
    end
end

