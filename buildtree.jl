using DataStructures

#cliqex = [["D", "E", "F"], ["E", "G", "H"], ["C", "E", "G"], ["A", "B", "C"], ["B", "C", "D"], ["C", "D", "E"]]
cliqex = [["D", "E", "F"], ["E", "G", "H"], ["C", "E", "G"], ["A", "B", "D"], ["A", "C", "E"], ["A", "D", "E"]]
cliqexnames = join.(cliqex)
sort!(cliqex, by = x -> (x[1],x[2],x[3]))
println("\ncliques\n",cliqex)

A = [.5 .5]
B = [.5 .5;.4 .6]
C = [.7 .3;.2 .8]
D = [.9 .1;.5 .5]
E = [.3 .7;.6 .4]
F = [.01 .99;.01 .99; .01 .99; .99 .01]
G = [.8 .2; .1 .9]
H = [.05 .95; .95 .05; .95 .05; .95 .05]

CPTs = [A,B,C,D,E,F,G,H]
CPTnames = ["A", "B", "C", "D", "E", "F", "G", "H"]
CPTlist = ["A", "B", "C", "D", "E", "F", "G", "H"]

dag = [0 1 1 0 0 0 0 0; 0 0 0 1 0 0 0 0; 0 0 0 0 1 0 1 0; 0 0 0 0 0 1 0 0; 0 0 0 0 0 1 0 1; 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 1; 0 0 0 0 0 0 0 0]

theta = []

mutable struct sepset
    parent
    child1
    vs
    mass
    cost
end
sepset() = sepset(-1,-1,[],-1,-1)

function vweight(v)
    index = findfirst(x -> x == v,CPTlist)
    cpt = CPTs[index]
    size(cpt)[2]
end

function sweight(s)
    vweight(s[1]) *  vweight(s[2]) * vweight(s[3])
end

function cost(sepset)
   sweight(sepset.parent) + sweight(sepset.child1)
end

function mass(sepset)
    size(sepset.vs)[1]
end


#get each sepset, sort by increasing order mass then cost
function getsepsets(cliqueset, names)
    n = size(cliqueset)[1]
    for i in 1:n-1
        for j in i+1:n
            ss = sepset()
            ss.parent = cliqueset[i]
            ss.child1 = cliqueset[j]
            vs = []
            for k in cliqueset[i]
                if k in cliqueset[j]
                    push!(vs,k)
                end
            end
            ss.vs = vs
            ss.cost = cost(ss)
            ss.mass = mass(ss)
            push!(theta,ss)   
        end 
              
    end
    sort(theta, by = x -> (x.mass,x.cost))        
end

spst = getsepsets(cliqex, cliqexnames)
println("\nsepsets\n",spst)

mutable struct node
    name
    e1
    e2
    e3
end
node(name) = node(name,-1,-1,-1)
node(name,e1) = node(name,e1,-1,-1)

#initialize tree
function buildtrees(cliquearray)
    trees = []
    for i in cliqex
        nd = node(i)
        push!(trees,[nd])
    end
    trees
end

trees = buildtrees(cliqex)
println("\ntrees\n")
println.(trees)

function search(key, index)
    v = false
    node = trees[index][1]
    tmp = []
    for i in trees[index]
        push!(tmp,i.name)
    end
    k = findfirst(x -> x == key,tmp)
    if k !== nothing 
        v = true
        node = trees[index][k]
    end
    [v,node]
end

function addsepset(trees, sepset)
    ss = pop!(sepset)
    println("\n", ss)
    #get trees of cluster parents
    r = [-1 -1]
    na = [node("-1"), node("-1")]
    p1 = node("-1")
    p2 = node("-1")
    for i in 1:size(trees)[1]
        p1 = search(ss.parent,i)
        if p1[1]
            r[1] = i
            na[1] = p1[2]
        end
        p2 = search(ss.child1,i)
        if p2[1]
            r[2] = i
            na[2] = p2[2]
        end
    end
    if r[1] != r[2]
        #combine trees right to left
        nn = node(ss.vs,ss.parent,ss.child1,-1)
        if r[1] > r[2]
            push!(trees[r[2]],nn)
            append!(trees[r[2]],trees[r[1]])
            deleteat!(trees,r[1])
        else
            push!(trees[r[1]],nn)
            append!(trees[r[1]],trees[r[2]])
            deleteat!(trees,r[2])
        end
        for i in 1:2
            if na[i].e1 == -1
                na[i].e1 = ss.vs
            elseif na[i].e2 == -1
                na[i].e2 = ss.vs
            else
                na[i].e3 = ss.vs
            end
        end
    end
end

n = size(trees)[1]
for i in 1:n-1
    addsepset(trees,spst)
    println("\ntrees after adding sepset ", i, "\n")
    println.(trees)
end

tree = trees[1]
sort!(tree, by = x -> (size(x.name)[1], x.name[1], x.name[2]))

println("\nNodes in tree\n")
for i in 1:size(tree)[1]
    nd = tree[i]
    if size(nd.name)[1] == 2
        println("Sepset: ", join(nd.name), " Edges: ", join(nd.e1), " ", join(nd.e2))
    else
        print("Cluster: ", join(nd.name), " Edges: ", join(nd.e1))
        if nd.e2 != -1
            print(" ", join(nd.e2))
            if nd.e3 != -1
                print(" ", join(nd.e3))
            end
        end
        print("\n")
    end
end

#initialize
function getparents(v)
    result = []
    ind = findfirst(x -> x == v,CPTlist)
    col = dag[:,ind]
    cptind = findall(x -> x == 1, col)
    for i in cptind
        push!(result,getindex(CPTlist,i))
    end
    result
end

#create potential and set each element to 1
function onepo(node)
    vs = node.name
    size = 1
    for i in vs
        size *= vweight(i)
    end
    ones(size)
end

potentials = Dict{Array, Array}()

for i in tree
    potentials[i.name] = onepo(i)
end
for i in keys(potentials)
    println(i, " ", potentials[i])
end