# Pkg.add("ProgressMeter")
using ProgressMeter

function readSparseBinaryMatrixFromSNAP(filename)
    f = open(filename)

    # this part is for progress meter
    seekend(f)
    fileSize = position(f)
    seekstart(f)
    progressMapping = Progress(fileSize, 1, "Building indices mapping...")

    #creating a mapping
    indicesMapping = Dict{Int, Int}();
    i = 1
    while !eof(f)
        fileline = readline(f)
        if fileline[1] == '#'
            continue
        end
        matches = matchall(r"\d+", fileline)
        indexLeft = parse(Int,matches[1]);
        indexRight = parse(Int,matches[2]);
        if !haskey(indicesMapping, indexLeft)
            indicesMapping[indexLeft] = i
            i = i + 1
        end

        if !haskey(indicesMapping, indexRight)
            indicesMapping[indexRight] = i
            i = i + 1
        end
        update!(progressMapping, position(f))
    end

    #  reset file position to ist beginning
    seekstart(f)
    binaryMatrix = spzeros(i - 1, i - 1);
    # this part is for progress meter
    progressMatrix = Progress(fileSize, 1, "Building binary matrix ...")

    #build final matrix
    while !eof(f)
        fileline = readline(f)
        if fileline[1] == '#'
            continue
        end
        matches = matchall(r"\d+", fileline)
        indexLeft = parse(Int,matches[1]);
        indexRight = parse(Int,matches[2]);
        binaryMatrix[indicesMapping[indexLeft], indicesMapping[indexRight]] = 1
        update!(progressMatrix, position(f))
    end

    # close file
    close(f)

    return binaryMatrix;
end
