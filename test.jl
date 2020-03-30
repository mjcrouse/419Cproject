#using LinearAlgebra

dag = [0 1 1 0 0 0 0 0; 0 0 0 1 0 0 0 0; 0 0 0 0 1 0 1 0; 0 0 0 0 0 1 0 0; 0 0 0 0 0 1 0 1; 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 1; 0 0 0 0 0 0 0 0]

#TODO connect names of nodes to dag
A = [.5 .5]
B = [.5 .5;.4 .6]
C = [.7 .3;.2 .8]
D = [.9 .1;.5 .5]
E = [.3 .7;.6 .4]
F = [.01 .99;.01 .99; .01 .99; .99 .01]
G = [.8 .2; .1 .9]
H = [.05 .95; .95 .05; .95 .05; .95 .05]

CPTs = [A,B,C,D,E,F,G,H]

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

#nodes = ["A", "B", 'C', 'D', 'E', 'F', 'G', 'H']
#println(nodes)

f = []
clusters = []
#check without weights for now (get fewest edges added)
function check(g) #input moral graph
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
    println(a) 
    #f = []
    min = minimum(a)
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

function weight(nd) #input node, return weight of corresponding node cluster
    w = 0
    println(clusters[nd])
    for i in clusters[nd]
        cpt = CPTs[i]
        println(size(cpt)[2])
        w += size(cpt)[2]
    end
    return w
end

for i in f
    println(i, " ", weight(i))
end