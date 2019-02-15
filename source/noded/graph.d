module noded.graph;

import rx;
import noded.port;
import noded.node;

class Graph{
    private alias this This;
    public {

        This add(Node node){
            _nodes ~= node;
            node.changeStruct.doSubscribe!((ChangeStructEvent e){
                auto sortedDAG = e.affectedNodes.topsortNode;
                foreach (node; sortedDAG) {
                    node.update();
                }
            });

            node.changeValue.doSubscribe!((ChangeValueEvent e){
                auto sortedDAG = e.affectedNodes.topsortNode;
                foreach (node; sortedDAG) {
                    node.update();
                }
            });
            return this;
        }

        This remove(Node node){
            import std.algorithm;
            _nodes = _nodes.remove!(a => a == node);
            return this;
        }

        This saveNode(){
            return this;
        }

        This loadNode(){
            return this;
        }

        size_t numNodes(){
            return _nodes.length;
        }

    }

    private{
        Node[] _nodes;
    }
}

Node[] topsortNode(Node[] nonsorted){
    import topologicalsort;
    return nonsorted.generateDAG
                    .topologicalSort;
}

unittest{
    auto node = new Node;
    auto graph = new Graph;
    graph.add(node);
    assert(graph.numNodes == 1);
    graph.remove(node);
    assert(graph.numNodes == 0);
}

private Node[][] generateDAG(Node[] nodes){
    Node[][] result;
    foreach (node; nodes) {
        auto from = node;
        foreach (output; node.outputs) {
            foreach (port; output.connections) {
                auto to = port.base;
                result ~= [from, to];
            }
        }
    }
    return result;
}

unittest{
    auto node1 = new Node();
    node1.outputs ~= port!float(node1);
    auto node2 = new Node();
    node2.inputs ~= port!float(node2);
    node2.outputs ~= port!float(node2);
    auto node3 = new Node();
    node3.inputs ~= port!float(node3);
    node3.outputs ~= port!float(node3);
    auto node4 = new Node();
    node4.inputs ~= port!float(node4);
    node4.outputs ~= port!float(node4);

    node1.outputs[0].addConnection(node2.inputs[0]);
    node1.outputs[0].addConnection(node3.inputs[0]);
    node2.outputs[0].addConnection(node4.inputs[0]);
    node3.outputs[0].addConnection(node4.inputs[0]);

    auto nodes = [node2, node1, node4, node3];
    auto sorted = nodes.topsortNode;
    assert(sorted[0] == nodes[1]);
    assert(sorted[3] == nodes[2]);
}
