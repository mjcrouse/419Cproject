using DataStructures

cliques = [["D", "E", "F"], ["E", "G", "H"], ["C", "E", "G"], ["A", "B", "C"], ["B", "C", "D"], ["C", "D", "E"]]
cliqex = [["D", "E", "F"], ["E", "G", "H"], ["C", "E", "G"], ["A", "B", "D"], ["A", "C", "E"], ["A", "D", "E"]]
cliqexnames = ["DEF","EGH","CEG","ABD","ACE","ADE"] #concat sorted clique arrays into 1
cliquesnames = ["DEF","EGH","CEG","ABC", "BCD", "CDE"]
#println(cliques)
println("\nclique\n",cliqex)

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

theta = []

#add types
mutable struct sepset
    #name
    parent
    child1
    vs
    mass
    cost
end
sepset() = sepset(-1,-1,[],-1,-1)

#these functions could be simpler = format
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


#get each sepset, sort by increasing order
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
    parent
    child1
    child2
end
node(name) = node(name,-1,-1,-1)
node(name,parent) = node(name,parent,-1,-1)

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

#= function search(key,root)
    v = false
    node = root
    if root.name == key
       global v = true
    elseif root.child1 == -1 && root.child2 == -1
    else
        root.child1 == -1 || search(key,root.child1)
        root.child2 == -1 || search(key,root.child2)
    end
    [v,node]
end =#

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
        #println(r)
        #combine trees

#=         #case 1 left node free child right node no parent
        if (na[1].child1 == -1 || na[2].child2 == -1) && na[2].parent == -1
            if na[1].child1 == -1 && na[2].child2 == -1
                na[1].child1 = ss
            else
                na[1].child2 = ss
            end
            na[2].parent = ss
            nn = node(ss.vs,ss.parent,ss.child1,-1)
            push!(nodes,nn)
        end
        #case 2 left node free child right node has parent
        if na[1].child1 == -1 && na[2].parent != -1
            na[1].child1 = ss
            if na[2].child1 == -1
                na[2].child1 == na[2].parent
                na[2].parent == ss
            else
                na[2].child2 == na[2].parent
                na[2].parent == ss
            end
        end =#

        #combine trees right to left
        nn = node(ss.vs,ss.parent,ss.child1,-1)
        println(r[1], " ", r[2])
        if r[1] > r[2]
            push!(trees[r[2]],nn)
            append!(trees[r[2]],trees[r[1]])
            deleteat!(trees,r[1])
        else
            push!(trees[r[1]],nn)
            append!(trees[r[1]],trees[r[2]])
            deleteat!(trees,r[2])
        end
    end
    # add node 
    #nn = node(ss.vs,-1,0,0)

    #recalc
end

#test
#= tree = node(["D"])
a = node(["D","E","F"], tree,-1,-1)
b = node(["E", "G", "H"], tree,-1,-1)
tree.parent = a
tree.child1 = b

println(search(["E", "G"],trees)) =#

addsepset(trees,spst)
println("\ntrees after adding first sepset\n")
println.(trees)
addsepset(trees,spst)
println("\ntrees after adding second sepset\n")
println.(trees)
addsepset(trees,spst)
println("\ntrees after adding third sepset\n")
println.(trees)
addsepset(trees,spst)
println("\ntrees after adding fourth sepset\n")
println.(trees)
addsepset(trees,spst)
println("\ntrees after adding fifth sepset\n")
println.(trees)

println.(trees[1])

#update nodes for correct children/parents?
#sort? pretty print
#what do I need for initializing?
