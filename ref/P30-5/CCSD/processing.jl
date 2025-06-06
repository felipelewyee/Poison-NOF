using YAML
using Printf

template = """
memory 20Gb

molecule{
xyz}

set reference rhf

properties(\"CCSD/def2-QZVP\", properties=[\"NO_OCCUPATIONS\"])
"""

data = YAML.load_file("Reactions.yaml")

for (reaction, reaction_data) in data
    println(reaction)
    set_name, reaction_id = split(reaction, ":")
    molecules = reaction_data[2:end]
    for (coeff, xyzfile) in molecules
        println(xyzfile)
        xyz = ""
	mult = 0
        for (i, line) in enumerate(eachline(xyzfile))
            if (i==2)
		charge, mult = split(line)
		mult = parse(Int64,mult)
                xyz = xyz * line * "\n"
            elseif (i>=2)
                atom, x, y, z = split(line)
		atom = uppercasefirst(atom)
		formatted_line = atom * "     " * x * "  " * y * "  " * z 
                xyz = xyz * formatted_line * "\n"
            end
        end

        molecule_name = xyzfile[1:(end-4)]
        open(molecule_name*".in", "w") do fmol
            content = replace(template, "xyz" => xyz)
            content = replace(content, "rrrr" => molecule_name)
	    if mult > 1
                content = replace(content, "rhf" => "rohf")
            end
            print(fmol, content)
        end
    end
end
