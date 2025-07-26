using YAML
using Printf

wd = split(pwd(), "/")
path = wd[1:end-2]
benchmark = wd[end-1]

template = """
using DoNOF

mol = \"\"\"
xyz\"\"\"

bset,p = DoNOF.molecule(mol,"def2-qzvp",spherical=true)

p.title = \"rrrr\"

p.ipnof = 8

p.RI = true
p.maxit = 40

p.maxloop = 10

DoNOF.set_ncwo(p,1)

C = DoNOF.read_C(title=p.title)
n = DoNOF.read_n(title=p.title)

DoNOF.energy(bset,p,C=C,n=n,do_hfidr=false,do_m_diagnostic=true)
"""

# Read yaml and look for unique molecules
data =  YAML.load_file(join(vcat(path[1:end-1], [benchmark, benchmark * ".yaml"]), "/"))
mols_in_sets = []
for (reaction, reaction_data) in data
    set_name, reaction_id = split(reaction, ":")
    molecules = reaction_data[2:end]
    for (coeff, xyzfile) in molecules
	push!(mols_in_sets, set_name * "-" * xyzfile[1:end-4])
    end
end
molecules = Set(mols_in_sets)
println(molecules)

# Generate the input files
for mol in molecules
    xyz = ""
    xyzdir = join(vcat(path[1:end-1], [benchmark, mol * ".xyz"]), "/")
    for (i, line) in enumerate(eachline(xyzdir))
        if (i>=2)
            xyz = xyz * line * "\n"
        end
    end
    open(mol*".jl", "w") do fmol
        content = replace(replace(template, "xyz" => xyz), "rrrr" => mol)
        print(fmol, content)
    end
end
