using DoNOF

mol = """
0 2
Cl       0.000000    0.000000    0.000000 
"""

bset,p = DoNOF.molecule(mol,"def2-qzvp",spherical=true)

p.title = "W4-11-cl"

p.ipnof = 8
p.ista = 4

p.RI = true
p.maxit = 40

p.maxloop = 10

#DoNOF.set_ncwo(p,1)

C = DoNOF.read_C(title=p.title)
n = DoNOF.read_n(title=p.title)

DoNOF.energy(bset,p,C=C,n=n,do_hfidr=false,do_m_diagnostic=true)
