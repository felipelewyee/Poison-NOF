using YAML
using Printf
using Statistics

wd = split(pwd(), "/")
nof = wd[end]
benchmark = wd[end-1]
ncwo = wd[end-2] 
path = wd[1:end-2]
benchnames = ["P30-5", "P30-10", "P30-20"]

data =  YAML.load_file(join(vcat(path[1:end-1], [benchmark, benchmark * ".yaml"]), "/"))
nsystems = length(data)

function build_path(rootdir, benchname, nof, filename)
    # Construct the path to the output file.
    # The path is constructed by joining the root directory, set name, nof, and filename.

    path = joinpath("/", rootdir, benchname, nof, filename * ".out")
    return path
end

function get_data_fromfile(file, phrase, idx)
    # Try to open the file and get data.
    # Look for the phrase and return the value at id
    # If it does not success, return 0.

    try
        Emol = "0"
        open(file, "r") do fmol
            for linemol in readlines(fmol)
                if occursin(phrase, linemol)
                    Emol = split(linemol)[idx]
                end
            end
        end
        return Emol
    catch
        return "0"
    end
end

function get_nof_E(nof, filename, set_name, reaction_id)
    # Try to get the NOF energy.
    # First, it looks the exact filename in P30-5.
    # If it does not find, it looks the molecule in the other reactions within the same set.
    phrase = "Final NOF"
    idx = 6

    # Root directory. First part is empty. Last two parts are set and nof
    fileparts = split(pwd(), "/")[2:end-2]
    rootdir = join(fileparts, "/")

    # Look exact filename for a specfic reaction in all benchmarks
    # (in case we have moved the Ncwo of a molecule in a specific reaction)
    for benchname in benchnames
        dir = build_path(rootdir, benchname, nof, set_name * "-" * reaction_id * "-" * filename)
        Emol = get_data_fromfile(dir, phrase, idx)
        Emol = parse(Float64, Emol)
        if Emol < 0
            return Emol, filename
        end
    end

    # Look exact filename in all benchmarks
    # (this is the general case, one molecule is generally shared by many reactions)
    for benchname in benchnames
        dir = build_path(rootdir, benchname, nof, set_name * "-" * filename)
        Emol = get_data_fromfile(dir, phrase, idx)
        Emol = parse(Float64, Emol)
        if Emol < 0
            return Emol, filename
        end
    end

    println("Energy not found:", filename)
    return 0, filename
end

function get_nof_ncwo(nof, filename, set_name, reaction_id)
    # Try to get the NOF ncwo.
    # First, it looks the exact filename in P30-5.
    # If it does not find, it looks the molecule in the other reactions within the same set.
    phrase = "NCWO"
    idx = 12

    # Root directory. First part is empty. Last two parts are set and nof
    fileparts = split(pwd(), "/")[2:end-2]
    rootdir = join(fileparts, "/")

    # Look exact filename for a specfic reaction in all benchmarks
    # (in case we have moved the Ncwo of a molecule in a specific reaction)
    for benchname in benchnames
        dir = build_path(rootdir, benchname, nof, set_name * "-" * reaction_id * "-" * filename) 
        ncwo = get_data_fromfile(dir, phrase, idx)
        ncwo = parse(Int32, ncwo)
        if ncwo > 0
            return ncwo, filename
        end
    end

    # Look exact filename in all benchmarks
    # (this is the general case, one molecule is generally shared by many reactions)
    for benchname in benchnames
        dir = build_path(rootdir, benchname, nof, set_name * "-" * filename)
        ncwo = get_data_fromfile(dir, phrase, idx)
        ncwo = parse(Int32, ncwo)
        if ncwo > 0
            return ncwo, filename
        end
    end

    return 0, filename

end

#########################################
# results: All sets
# systems: All reactions in a set
# species: A given reaction
# mol_data: All molecules in a reaction
# prop: A given molecule
#########################################

# Generate Structure of Results
# Each Set has its Dict entry
results = Dict()
for (reaction, reaction_data) in data
    set_name, reaction_id = split(reaction, ":")
    results[set_name] = Dict()
end

ADs = Dict()  #Absolute Deviations
APDs = Dict() #Absolute Percentual Deviation
# Check each reaction in the Data Set
for (reaction, reaction_data) in data
    println("--------------------------------------")
    println(reaction)
    println("--------------------------------------")

    # Get reaction data
    species = Dict() # Store info of a given reaction
    set_name, reaction_id = split(reaction, ":")
    dE_Ref = reaction_data[1]
    molecules = reaction_data[2:end]
    
    mol_data = Dict() # Store info of the molecules in a reaction
    dE_NOF = 0
    # Check each molecule in the reaction
    for (count, xyzfile) in molecules
	prop = Dict() # Store info of a given molecule
        mol_name = xyzfile[1:end-4]
        path_to_xyz = join(vcat(path[1:end-1], [benchmark, set_name * "-" * mol_name * ".xyz"]), "/")
        charge, mult = split(readlines(path_to_xyz)[2])

        E_NOF,filename = get_nof_E(nof, mol_name, set_name, reaction_id)
        ncwo_NOF,_ = get_nof_ncwo(nof, mol_name, set_name, reaction_id)
        @printf(" %-20s %3d %10.4f\n", mol_name, count, E_NOF)

        dE_NOF += count*E_NOF*627.5

        prop["Charge"] = charge
        prop["Multiplicity"] = mult
        prop["E_NOF"] = E_NOF
        prop["Ncwo"] = ncwo_NOF
        prop["Count"] = count
        prop["Filename"] = filename * ".xyz"
        mol_data[mol_name] = prop
    end

    # Compute Error metrics
    @printf("dE_Ref: %10.3f\n",dE_Ref)
    @printf("dE_NOF: %10.3f\n",dE_NOF)
    AD = abs(dE_NOF-dE_Ref)
    APD = abs((dE_NOF-dE_Ref)/dE_Ref) * 100
    @printf("AD: %10.3f\n", AD)
    ADs[reaction] = AD
    APDs[reaction] = APD

    # Save data
    species["dE_Ref"] = dE_Ref
    species["dE_NOF"] = dE_NOF
    species["Species"] = mol_data
    species["AD"] = AD
    species["APD"] = APD

    results[set_name][reaction_id] = species

end

outlayers = [key for (key, value) in ADs if value > 100]
if length(outlayers) > 1
    println("I am going to drop the following reactins as AD is too high")
    for reaction in outlayers
        println(reaction, " ", round(ADs[reaction]))
	pop!(ADs, reaction)
    end
end
@printf("MAD = %.1f\n", mean(values(ADs)))

YAML.write_file(benchmark*"-"*nof*"-"*ncwo*".yaml", results)
