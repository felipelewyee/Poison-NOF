using YAML
using Printf
using Statistics

wd = split(pwd(), "/")
path = wd[1:end-2]
benchmark = wd[end-1]
nof = wd[end]

data =  YAML.load_file(join(vcat(path[1:end-1], [benchmark, benchmark * ".yaml"]), "/"))

files = readdir()

mols = []
for (reaction_name, reaction) in data
    set_name, system = split(reaction_name, ":")
    for info in reaction
        if(length(info) == 2)
            mol = info[2][1:end-4]
            push!(mols, set_name*"-"*string(mol))
        end
    end
end
mols = unique(mols)

for mol in mols
   deleteat!(files, findall(x->x==mol*".jl", files))
   deleteat!(files, findall(x->x==mol*".jld2", files))
   deleteat!(files, findall(x->x==mol*".fchk", files))
   deleteat!(files, findall(x->x==mol*".out", files))
end

for file in files
  rm(file, recursive=true)
end
