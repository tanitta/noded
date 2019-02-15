module noded.port;

import rx;
import noded.node;

struct TryAddEdgeEvent{
}

class Port{
    public{
        Node base;
        bool validateImpl(TypeInfo typeInfo){
            return _typeInfo == typeInfo;
        }

        Observable!TryAddEdgeEvent tryAddEdge(){
            return _tryAddEdge;
        }
        
        Port[] connections(){
            return _connections;
        }
    }

    private{
        Port[] _connections;
        this(){};
        TypeInfo _typeInfo;
        SubjectObject!TryAddEdgeEvent _tryAddEdge;
    }
}

Port port(T)(){
    auto port = new Port;
    port._typeInfo = typeid(T);
    return port;
}
Port port(T)(Node base){
    auto port = new Port;
    port.base = base;
    port._typeInfo = typeid(T);
    return port;
}

bool validate(Port port, TypeInfo t){
    return port.validateImpl(t);
};

unittest{
    auto port = port!float();
    assert(port.validate(typeid(float)));
}

bool validate(T)(Port port, T v)if(!is(T == TypeInfo)){
    return port.validateImpl(typeid(T));
};

unittest{
    auto port = port!float;
    assert(port.validate(1f));
}

bool validate(T)(Port port){
    return port.validateImpl(typeid(T));
};

unittest{
    auto port = port!float;
    assert(port.validate!(float));
}

void addConnection(Port from, Port to){
    import std.algorithm;
    if(from._connections.canFind(to) || to._connections.canFind(from))return;
    from._connections ~= to;
    to._connections ~= from;
}
