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

reg = ["W4-11", "G21EA", "G21IP", "DIPCS10", "PA26", "SIE4x4", "ALKBDE10", "YBDE18", "AL2X6", "HEAVYSB11", "NBPRC", "ALK8", "RC21", "G2RC", "BH76RC", "FH51", "TAUT15", "DC13"]
iso = ["MB16-43", "DARC", "RSE43", "BSR36", "CDIE20", "ISO34", "ISOL24", "C60ISO", "PArel"]
bh  = ["BH76", "BHPERI", "BHDIV10", "INV24", "BHROT27", "PX13", "WCPT18"]
nci = ["RG18", "ADIM6", "S22", "S66", "HEAVY28", "WATER27", "CARBHB12", "PNICO23", "HAL59", "AHB21", "CHB6", "IL16",
        "IDISP", "ICONF", "ACONF", "Amino20x4", "PCONF21", "MCONF", "SCONF", "UPU23", "BUT14DIOL"]

weights = Dict("W4-11" => 0.1852, "G21EA" => 1.6913, "G21IP" => 0.2206, "DIPCS10" => 0.0869, "PA26" => 0.3007,"SIE4x4" => 1.6854, "ALKBDE10" => 0.5645, "YBDE18" => 1.1535,  "AL2X6" => 1.5840, "HEAVYSB11" => 0.9796, "NBPRC" => 6.5396, "ALK8" => 0.9080, "RC21" => 1.6245, "G2RC" => 1.1088, "BH76RC" => 2.7386, "FH51" => 1.8329, "TAUT15" => 26.7861, "DC13" => 3.8956,
"MB16-43" => 0.1259, "DARC" => 1.7505, "RSE43" => 8.4077, "BSR36" => 3.5093, "CDIE20" => 23.6341, "ISO34" => 3.9012, "ISOL24" => 2.5932, "C60ISO" => 0.5785, "PArel" => 12.2751,
"BH76" => 3.1251, "BHPERI" => 2.7231, "BHDIV10" => 1.2538, "INV24" => 1.7848, "BHROT27" => 9.0611, "PX13" => 1.7038, "WCPT18" => 1.6246,
"RG18" => 98.0000, "ADIM6" => 16.9251, "S22" => 7.7838, "S66" => 10.3970, "HEAVY28" => 45.7860, "WATER27" => 0.7005, "CARBHB12" => 9.4179, "PNICO23" => 13.3006, "HAL59" => 12.3775, "AHB21" => 2.5278, "CHB6" => 2.1221, "IL16" => 0.5213,
"IDISP" => 5.0795, "ICONF" => 17.4010, "ACONF" => 30.9901, "Amino20x4" => 23.3076, "PCONF21" => 35.0504, "MCONF" => 11.4344, "SCONF" => 12.3565, "UPU23" => 9.9325, "BUT14DIOL" => 20.3023)

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

notfound = []

ADs_reg = Dict()
ADs_iso = Dict()
ADs_bh = Dict()
ADs_nci = Dict()
WADs_reg = Dict()
WADs_iso = Dict()
WADs_bh = Dict()
WADs_nci = Dict()

ADs = Dict()  #Absolute Deviations
APDs = Dict() #Absolute Percentual Deviation
WADs = Dict()  #Weighted Absolute Deviations
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
	if E_NOF == 0
            push!(notfound, set_name * "-" * filename)
	end
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
    WADs[reaction] = weights[set_name] * AD

    if(set_name in reg)
        ADs_reg[reaction] = AD
        WADs_reg[reaction] = weights[set_name] * AD
    elseif(set_name in iso)
        ADs_iso[reaction] = AD
        WADs_iso[reaction] = weights[set_name] * AD
    elseif(set_name in bh)
        ADs_bh[reaction] = AD
        WADs_bh[reaction] = weights[set_name] * AD
    elseif(set_name in nci)
        ADs_nci[reaction] = AD
        WADs_nci[reaction] = weights[set_name] * AD
    end

    # Save data
    species["dE_Ref"] = dE_Ref
    species["dE_NOF"] = dE_NOF
    species["Species"] = mol_data
    species["AD"] = AD
    species["APD"] = APD

    results[set_name][reaction_id] = species

end

outlayers = [key for (key, value) in ADs if value > 50]
if length(outlayers) > 1
    println("I am going to drop the following reactins as AD is too high")
    for reaction in outlayers
        println(reaction, " ", round(ADs[reaction]))
	pop!(ADs, reaction)
	pop!(WADs, reaction)
    end
end
@printf("MAD = %.1f\n", mean(values(ADs)))
@printf("WTMAD2 = %.1f\n", mean(values(WADs)))

YAML.write_file(benchmark*"-"*nof*"-"*ncwo*".yaml", results)

println("Not Found")
for mol in notfound
    println(mol, " ")
end

###### Analysis per reg, iso, bh, nci ####
#for (label, ADs, WADs) in zip(["Reg", "Iso", "BH", "NCI"], [ADs_reg, ADs_iso, ADs_bh, ADs_nci], [WADs_reg, WADs_iso, WADs_bh, WADs_nci])
#    println("======== ", label, " ========")
#    outlayer = [key for (key, value) in ADs if value > 50]
#    if length(outlayer) > 1
#        println("I am going to drop the following reactins as AD is too high")
#        for reaction in outlayer
#            println(reaction, " ", round(ADs[reaction]))
#            pop!(ADs, reaction)
#            pop!(WADs, reaction)
#        end
#    end
#    @printf("MAD = %.1f\n", mean(values(ADs)))
#    @printf("WTMAD2 = %.1f\n", mean(values(WADs)))
#end
