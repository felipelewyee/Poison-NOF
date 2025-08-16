using DoNOF

mol = """
0 1
F        0.900915    0.900915    0.900915 
Si       0.000000    0.000000    0.000000 
F       -0.900915   -0.900915    0.900915 
F       -0.900915    0.900915   -0.900915 
F        0.900915   -0.900915   -0.900915 
"""

bset,p = DoNOF.molecule(mol,"def2-qzvp",spherical=true)

p.title = "W4-11-sif4"

p.ipnof = 8

p.RI = true
p.maxit = 40

p.maxloop = 10

#DoNOF.set_ncwo(p,1)

C = DoNOF.read_C(title=p.title)
n = DoNOF.read_n(title=p.title)

DoNOF.energy(bset,p,C=C,n=n,do_hfidr=false,do_m_diagnostic=true)
