using YAML
using Printf

wd = split(pwd(), "/")
path = wd[1:end-2]
benchmark = wd[end-1]
nof = wd[end]

function get_molecules(data)

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

    return mols

end


data_5 =  YAML.load_file(join(vcat(path[1:end-1], ["P30-5", "P30-5.yaml"]), "/"))
data_10 =  YAML.load_file(join(vcat(path[1:end-1], ["P30-10", "P30-10.yaml"]), "/"))
data_20 =  YAML.load_file(join(vcat(path[1:end-1], ["P30-20", "P30-20.yaml"]), "/"))

mols_5 = get_molecules(data_5)
mols_10 = get_molecules(data_10)
mols_20 = get_molecules(data_20)

repeated = []
if benchmark == "P30-10"
    mols_10_in_5 = intersect(mols_10, mols_5)
    repeated = vcat(repeated, mols_10_in_5)
    println("Repeated with 5:")
    println(mols_10_in_5)
end

if benchmark == "P30-20"
    mols_20_in_5 = intersect(mols_20, mols_5)
    repeated = vcat(repeated, mols_20_in_5)
    println("Repeated with 5:")
    println(mols_20_in_5)

    mols_20_in_10 = intersect(mols_20, mols_10)
    repeated = vcat(repeated, mols_20_in_10)
    println("Repeated with 10:")
    println(mols_20_in_10)
end

for molecule_name in repeated
    println(string(molecule_name))
    rm(string(molecule_name)*".jl", force=true)
    rm(string(molecule_name)*".jld2", force=true)
    rm(string(molecule_name)*".fchk", force=true)
    rm(string(molecule_name)*".out", force=true)
end
