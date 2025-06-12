using YAML
using Printf
using Statistics

wd = split(pwd(), "/")
nof = wd[end]
superset = wd[end-1]
ncwo = wd[end-2] 

data = YAML.load_file("Reactions.yaml")
nsystems = 30

function build_path(rootdir, setname, nof, filename)
    # Construct the path to the output file.
    # The path is constructed by joining the root directory, set name, nof, and filename.

    path = joinpath("/", rootdir, setname, nof, filename * ".out")
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

function get_nof_E(nof, filename, subset_name, reaction_id)
    # Try to get the NOF energy.
    # First, it looks the exact filename in P30-5.
    # If it does not find, it looks the molecule in the other reactions within the same set.
    phrase = "Final NOF"
    idx = 6

    # Root directory. First part is empty. Last two parts are set and nof
    fileparts = split(pwd(), "/")[2:end-2]
    rootdir = join(fileparts, "/")

    # Look exact filename in all sets
    for setname in ["P30-5"]
	if !occursin(subset_name, filename)
            try
                newname = join([subset_name,reaction_id,filename],"_")
                dir = build_path(rootdir, setname, nof, newname)
                Emol = get_data_fromfile(dir, phrase, idx)
                Emol = parse(Float64, Emol)
                if Emol < 0
                    return Emol, newname
                end
            catch
                nothing
            end
        end
        dir = build_path(rootdir, setname, nof, filename) # end-4 to remove xyz
        Emol = get_data_fromfile(dir, phrase, idx)
        Emol = parse(Float64, Emol)
        if Emol < 0
            return Emol, filename
        end
    end

    println("Energy not found:", filename)
    return 0, nothing
end

function get_nof_ncwo(nof, filename, subset_name, reaction_id)
    # Try to get the NOF ncwo.
    # First, it looks the exact filename in P30-5.
    # If it does not find, it looks the molecule in the other reactions within the same set.
    phrase = "NCWO"
    idx = 12

    # Root directory. First part is empty. Last two parts are set and nof
    fileparts = split(pwd(), "/")[2:end-2]
    rootdir = join(fileparts, "/")

    # Look exact filename in all sets
    for setname in ["P30-5"]
        if !occursin(subset_name, filename)
            try
                newname = join([subset_name,reaction_id,filename],"_")
                dir = build_path(rootdir, setname, nof, newname)
                ncwo = get_data_fromfile(dir, phrase, idx)
		if(parse(Float64, ncwo) > 0)
                    return ncwo, newname
	        end
            catch
                nothing
            end
        end
        dir = build_path(rootdir, setname, nof, filename)
        ncwo = get_data_fromfile(dir, phrase, idx)
        return ncwo, filename
    end

    return 0, nothing

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
    subset_name, reaction_id = split(reaction, ":")
    results[subset_name] = Dict()
end

ADs = Float64[]  #Absolute Deviations
APDs = Float64[] #Absolute Percentual Deviation
# Check each reaction in the Data Set
for (reaction, reaction_data) in data
    println("--------------------------------------")
    println(reaction)
    println("--------------------------------------")

    # Get reaction data
    species = Dict() # Store info of a given reaction
    subset_name, reaction_id = split(reaction, ":")
    dE_Ref = reaction_data[1]
    molecules = reaction_data[2:end]
    
    mol_data = Dict() # Store info of the molecules in a reaction
    dE_NOF = 0
    # Check each molecule in the reaction
    for (count, xyzfile) in molecules
	prop = Dict() # Store info of a given molecule
        mol_name = xyzfile[1:end-4]
        charge, mult = split(readlines(xyzfile)[2])

        E_NOF,filename = get_nof_E(nof, mol_name, subset_name, reaction_id)
        ncwo_NOF,_ = get_nof_ncwo(nof, mol_name, subset_name, reaction_id)
        @printf(" %-20s %3d %10.4f\n", mol_name, count, E_NOF)

        dE_NOF += count*E_NOF*627.5

        prop["Charge"] = charge
        prop["Multiplicity"] = mult
        prop["E_NOF"] = E_NOF
        prop["Ncwo"] = ncwo_NOF
        prop["Count"] = count
        prop["Filename"] = filename
        mol_data[mol_name] = prop
    end

    # Compute Error metrics
    @printf("dE_Ref: %10.3f\n",dE_Ref)
    @printf("dE_NOF: %10.3f\n",dE_NOF)
    AD = abs(dE_NOF-dE_Ref)
    APD = abs((dE_NOF-dE_Ref)/dE_Ref) * 100
    @printf("AD: %10.3f\n", AD)
    push!(ADs,AD)
    push!(APDs,APD)

    # Save data
    species["dE_Ref"] = dE_Ref
    species["dE_NOF"] = dE_NOF
    species["Species"] = mol_data
    species["AD"] = AD
    species["APD"] = APD

    results[subset_name][reaction_id] = species

end
@printf("MAD = %.1f\n", mean(ADs))

YAML.write_file(superset*"-"*nof*"-"*ncwo*".yaml", results)
