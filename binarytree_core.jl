using AbstractTrees

mutable struct BinaryNode{T}
    data
    parent::BinaryNode{T}
    left::BinaryNode{T}
    right::BinaryNode{T}
end
BinaryNode(data) = BinaryNode{typeof(data)}(data)

function leftchild(data, parent::BinaryNode)
    !isdefined(parent, :left) || error("left child is already assigned")
    node = typeof(parent)(data, parent)
    parent.left = node
end
function rightchild(data, parent::BinaryNode)
    !isdefined(parent, :right) || error("right child is already assigned")
    node = typeof(parent)(data, parent)
    parent.right = node
end