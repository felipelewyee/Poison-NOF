using YAML
using Printf

template = """
using DoNOF

mol = \"\"\"
xyz\"\"\"

bset,p = DoNOF.molecule(mol,"cc-pvtz",spherical=true)

p.title = \"rrrr\"

p.ipnof = 9

p.RI = true
p.maxit = 40

p.maxloop = 10

DoNOF.set_ncwo(p,1)
p.h_cut = 0.020*sqrt(2)

C = nothing#DoNOF.read_C(title=p.title)
n = nothing#DoNOF.read_n(title=p.title)

DoNOF.energy(bset,p,C=C,n=n,do_hfidr=false,do_m_diagnostic=true)
"""

data = YAML.load_file("Reactions.yaml")

for (reaction, reaction_data) in data
    println(reaction)
    set_name, reaction_id = split(reaction, ":")
    molecules = reaction_data[2:end]
    for (coeff, xyzfile) in molecules
        println(xyzfile)
        xyz = ""
        for (i, line) in enumerate(eachline(xyzfile))
            if (i==2)
                println(line)
                xyz = xyz * line * "\n"
            elseif (i>=2)
                atom, x, y, z = split(line)
		atom = uppercasefirst(atom)
		formatted_line = atom * "     " * x * "  " * y * "  " * z 
                xyz = xyz * formatted_line * "\n"
            end
        end

        molecule_name = xyzfile[1:(end-4)]
        open(molecule_name*".jl", "w") do fmol
            content = replace(replace(template, "xyz" => xyz), "rrrr" => molecule_name)
            print(fmol, content)
        end
    end
end
