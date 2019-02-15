module noded.node;

import rx;
import noded.port;

///
struct ChangeValueEvent {
    public{
        Node[] affectedNodes;
    }//public

    private{
    }//private
}//struct ChangeValueEvent

struct ChangeStructEvent{
    public{
        Node[] affectedNodes;
    }//public

    private{
    }//private
}//struct ChangeValueEvent

///
class Node {
    public{
        Port[] inputs;
        Port[] outputs;

        this(){
            _changeValue = new SubjectObject!ChangeValueEvent;
            _changeStruct = new SubjectObject!ChangeStructEvent;
        }

        Observable!ChangeValueEvent changeValue(){
            return _changeValue;
        }

        Observable!ChangeStructEvent changeStruct(){
            return _changeStruct;
        }

        Node update(){
            return this;
        }
    }//public

    private{
        SubjectObject!ChangeValueEvent _changeValue;
        SubjectObject!ChangeStructEvent _changeStruct;

    }
}//class Node

unittest{
    auto node = new Node();
    node.inputs ~= port!(float);
    assert(node.inputs[0].validate!(float));
}

private Node[] affectedNodes(Node node){
    Node[] result;
    foreach (output; node.outputs) {
        foreach (port; output.connections){
            result ~= port.base;
        }
    }
    return result;
}

unittest{
}

