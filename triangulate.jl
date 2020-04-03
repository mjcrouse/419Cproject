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

println("\ndag")
println(dag)

function moralgraph(dag)
    n = size(dag)[1]
    if n != size(dag)[2]
        error("dag must be an N x N matrix")
    end
    #remove graph direction(make dag symmetric)
    ug = deepcopy(dag)
    for m = 1:n-1
        for i = m+1:n
                if ug[m,i] == 1
                    ug[i,m] = 1
                end
        end
    end
    #=println("undirected graph")
    println(ug) =#
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
    println("\nmoral graph")
    println(mg,"\n")
    mg
end

ogmg = moralgraph(dag) #original moral graph
mg = deepcopy(ogmg)

#get fewest edges added and corresponding nodes
f = []
clusters = []
min = 100000
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
        end
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
    global min = minimum(a)
    for k in 1:length(a)
        if ( min == a[k])
            push!(f,k)
        end
    end
    f
end

f = check(mg)
#input node, return weight of corresponding node cluster (helper for loweight)
function weight(nd) 
    w = 0
    for i in clusters[nd]
        cpt = CPTs[i]
        w += size(cpt)[2]
    end
    w
end

#return node with lowest weight
function loweight(array)
    a = []
    for i in f
       push!(a,weight(i))
    end
    f[argmin(a)]
end

#add edges to moral graph and mg' and clique to cliques
cliques = []
function addedges(nd)
    c = clusters[nd]
    n = size(c)[1]
    for i in 2:n-1
        for j in 3:n
            mg[c[i],c[j]] = mg[c[j],c[i]] = 1
            k = findfirst(x -> x == CPTnames[i],CPTlist)
            l = findfirst(x -> x == CPTnames[j],CPTlist)
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

function triangulate()
    n = size(dag)[1]
    for x in 1:n-1
        getlo = loweight(f)
        if min > 0
            addedges(getlo)
        end
        global mg = delete(getlo)
        global f = check(mg)
    end    
end

triangulate()
println("\ntriangulated graph")
println(ogmg)
println("\ncliques")
println(cliques,"\n")

