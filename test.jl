#using LinearAlgebra

dag = [0 1 1 0 0 0 0 0; 0 0 0 1 0 0 0 0; 0 0 0 0 1 0 1 0; 0 0 0 0 0 1 0 0; 0 0 0 0 0 1 0 1; 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 1; 0 0 0 0 0 0 0 0]
#dag = [0 1 1 1 0 0 0 0 0 0 0 0;0 0 0 0 1 0 0 0 0 0 0 0; 0 0 0 0 0 1 0 0 0 0 0 0;0 0 0 0 0 0 1 0 0 0 0 0; 0 0 0 0 0 0 0 1 0 0 0 0; 0 0 0 0 0 0 0 0 1 0 0 0;0 0 0 0 0 0 0 0 0 1 0 0; 0 0 0 0 0 0 0 0 1 0 1 0; 0 0 0 0 0 0 0 0 0 0 0 1; 0 0 0 0 0 0 0 0 0 0 0 1; 0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0]

A = [.5 .5]
B = [.5 .5;.4 .6]
C = [.7 .3;.2 .8]
D = [.9 .1;.5 .5]
E = [.3 .7;.6 .4]
F = [.01 .99;.01 .99; .01 .99; .99 .01]
G = [.8 .2; .1 .9]
H = [.05 .95; .95 .05; .95 .05; .95 .05]

#= I = [1 1 1 1; 1 1 1 1]
J = [1 1 1; 1 1 1]
K = [1 1; 1 1]
L = [1 1 1 1 1; 1 1 1 1 1] =#

CPTs = [A,B,C,D,E,F,G,H]#,I,J,K,L]
CPTnames = ["A", "B", "C", "D", "E", "F", "G", "H"] # "I", "J", "K", "L"]
CPTlist = ["A", "B", "C", "D", "E", "F", "G", "H"] #"I", "J", "K", "L"]

println("dag")
println(dag)

n = size(dag)[1]

if n != size(dag)[2]
    error("dag must be an N x N matrix")
end

ug = deepcopy(dag)
#remove direction of graph (make dag symmetric)
for m = 1:n-1
    for i = m+1:n
            if ug[m,i] == 1
                ug[i,m] = 1
            end
    end
end

println("undirected graph")
println(ug)

mg = deepcopy(ug)

# connect parents to finish moral graph
for m = 3:n
    for i = 1:m-2
        for j = i+1:m-1
            if mg[m,i] == 1 && mg[m,j] == 1
                mg[i,j] = 1
                mg[j,i] = 1
            end
        end
    end
end

println("moral graph")
println(mg)

ogmg = deepcopy(mg) #original moral graph

f = []
clusters = []
min = 100000

#get fewest edges added and corresponding nodes
function check(g) #input moral graph
    global clusters = []
    n = size(g)[1]
    if n == 1
        return println("There is only 1 element in the array: ", CPTnames[1])
    end
    f = Int8[]
    a = zeros(Int8,n)
    for m = 1:n
        b = Int8[]
        cl = [m]
        counter = 0
        for i = 1:n
            if g[m,i] == 1
                push!(b,i)
                push!(cl,i)
            end
            #println(b)
        end
        #println(b)
        #println(cl)
        push!(clusters,cl)
        if (l = length(b)) > 1
            for x = 1:l
                for y = x+1:l
                    if g[(b[x]),(b[y])] == 0
                        counter += 1
                    end
                end
            end
        end
        a[m] = counter;
    end
    println("edges added if node selected")
    println(a) 
    #f = []
    global min = minimum(a)
    for k in 1:length(a)
        if ( min == a[k])
            push!(f,k)
        end
    end
    #println(clusters)
    return f
end

f = check(mg)
println("lowest\n", f)

function weight(nd) #input node, return weight of corresponding node cluster (helper for loweight)
    w = 0
    for i in clusters[nd]
        cpt = CPTs[i]
        w += size(cpt)[2]
    end
    return w
end

#return node with lowest weight
function loweight(array)
    a = []
    for i in f
       push!(a,weight(i))
    end
    return f[argmin(a)]
end

cliques = []

#add edges to moral graph and mg' and clique to cliques
function addedges(nd)
    c = clusters[nd]
    n = size(c)[1]
    for i in 2:n-1
        for j in 3:n
            mg[c[i],c[j]] = mg[c[j],c[i]] = 1
            k = findfirst(x -> x == CPTnames[i],CPTlist)
            #println(CPTnames[i])
            l = findfirst(x -> x == CPTnames[j],CPTlist)
            #println(CPTnames[j])
            #println(CPTlist)
            ogmg[k,l] = ogmg[l,k] = 1
        end
    end
end

function delete(nd) #delete node with lowest weight from moral graph
    c = clusters[nd]
    cliq = []
    for i in c
        push!(cliq,CPTnames[i])
    end
    if size(cliq)[1] == 3
        sort!(cliq)
        push!(cliques,cliq)
    end
    println("deleted node: ", CPTnames[nd])
    deleteat!(CPTnames,nd)
    return mg[1:end.!=nd,1:end.!=nd]
end

#(don't need to check/add edges once down to 3 nodes? but need to remove to finish algorithm???)
for x in 1:n-1
    println("clusters: ",clusters)
    getlo = loweight(f)
    #println("min: ", min)
    if min > 0
        addedges(getlo)
    end
    global mg = delete(getlo)
    global f = check(mg)
end    

println(ogmg)
println(cliques)

