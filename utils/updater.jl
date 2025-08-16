wd = split(pwd(), "/")
nof = wd[end]
ncwo = wd[end-2]

function search_Enof_in_file(filename::String)
    E = 1.0
    try
        open(filename, "r") do file
            for line in eachline(file)
                if occursin("Final NOF", line)
                    E = parse(Float64, split(line)[6])
                end
            end
        end
        return E
    catch
        return E
    end
end


items = out_files = [f for f in readdir(".") if endswith(f, ".out")]

path_concentrator = expanduser("~/") * "concentrator/" * ncwo * "/" * nof * "/"
for file in items
    E = search_Enof_in_file(file)
    file_concentrator = path_concentrator * file
    E_conc = search_Enof_in_file(file_concentrator)
    if(E > E_conc)
        mol = replace(file, ".out" => "")
        println("Moving ", mol, " ", E, " ", E_conc)
        try
            cp(path_concentrator * mol * ".jld2", mol * ".jld2", force = true)
            cp(path_concentrator * mol * ".out", mol * ".out", force = true)
        catch
            println("Error with " *  mol)
        end
    end
end
