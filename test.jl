using LinearAlgebra

dag = [0 1 1 0 0 0 0 0; 0 0 0 1 0 0 0 0; 0 0 0 0 1 0 1 0; 0 0 0 0 0 1 0 0; 0 0 0 0 0 1 0 1; 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 1; 0 0 0 0 0 0 0 0]
println("dag")
println(dag)

n = size(dag)[1]

if n != size(dag)[2]
    error("dag must be an N x N matrix")
end

sdag = dag
#remove direction of graph (make dag symmetric)
for m = 1:n-1
    for i = m+1:n
            if sdag[m,i] == 1
                sdag[i,m] = 1
            end
    end
end

println(sdag)

# connect parents to finish moral graph
for m = 3:n
    for i = 1:m-2
        for j = i+1:m-1
            if sdag[m,i] == 1 && sdag[m,j] == 1
                sdag[i,j] = 1
                sdag[j,i] = 1
            end
        end
    end
end
println("moral graph")
println(sdag)

nodes = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
println(nodes)

#check without weights for now
#function check(dag)

