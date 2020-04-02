using DataStructures

cliques = [["D", "E", "F"], ["E", "G", "H"], ["C", "E", "G"], ["A", "B", "C"], ["B", "C", "D"], ["C", "D", "E"]]
cliqex = [["D", "E", "F"], ["E", "G", "H"], ["C", "E", "G"], ["A", "B", "D"], ["A", "C", "E"], ["A", "D", "E"]]
cliqexnames = ["DEF","EGH","CEG","ABD","ACE","ADE"] #concat sorted clique arrays into 1
println(cliques)
println(cliqex)

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
#add types?
mutable struct sepset
    #name
    p1
    p2
    vs
    mass
    cost
end

function vweight(v)
    index = findfirst(x -> x == v,CPTlist)
    cpt = CPTs[index]
    return size(cpt)[2]
end

function sweight(s)
    return vweight(s[1]) *  vweight(s[2]) * vweight(s[3])
end

function cost(sepset)
   return sweight(sepset.p1) + sweight(sepset.p2)
end

function mass(sepset)
    return size(sepset.vs)[1]
end

sepset() = sepset(0,0,[],0,0)

function getsepsets(cliqueset, names)
    n = size(cliqueset)[1]
    println(n)
    for i in 1:n-1
        for j in i+1:n
            ss = sepset()
            ss.p1 = cliqueset[i]
            ss.p2 = cliqueset[j]
            vs = []
            for k in cliqueset[i]
                if k in cliqueset[j]
                    push!(vs,k)
                end
            end
            ss.vs = vs
            ss.cost = cost(ss)
            ss.mass = mass(ss)
            println(ss)
            push!(theta,ss)   
        end 
              
    end        
end

spst = getsepsets(cliqex, cliqexnames)
println(theta)

theta = sort(theta, by = x -> (x.mass,x.cost))
println(theta)

mutable struct clusternode
    name
    ss1
    ss2
    ss3
end

mutable struct ssnode
    name
    c1
    c2
end

function buildtree(cliquearray)

end

cn = clusternode()
println(cn)