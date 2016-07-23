# Pkg.add("ProgressMeter"); Pkg.add("MNIST"); Pkg.add("Distances"); Pkg.add("MAT")
using MAT
using MNIST
using Distances
using ProgressMeter

data, labels = MNIST.traindata();
data  = (data .- mean(data,2)) / std(data .- mean(data,2))


nrOfDataPoints = size(data,2)
K = 50;
similarityMatrix = spzeros(nrOfDataPoints, nrOfDataPoints);

@showprogress 1 "Computing euclidean distances between elements..." for i in 1:nrOfDataPoints
    distances = colwise(Euclidean(), data[:,i], data);
    neighbors = selectperm(distances, 1:(K+1));
    neighbors = neighbors[neighbors .!= i];
    similarityMatrix[neighbors,i] = 1
end

matlabFile = matopen("$YOUR_PATH/mnist.mat", "w")
write(matlabFile, "similarityMatrix", similarityMatrix);
write(matlabFile, "labels", labels);
close(matlabFile)
