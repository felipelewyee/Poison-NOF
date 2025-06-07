using DoNOF

mol = """
0 1
Mg     0.0000000  0.0000000  0.8639034
O     0.0000000  0.0000000  -0.8639034
"""

bset,p = DoNOF.molecule(mol,"cc-pvtz",spherical=true)

p.title = "ALKBDE10_7_mgo"

p.ipnof = 9

p.RI = true
p.maxit = 40

p.maxloop = 10

DoNOF.set_ncwo(p,1)
p.h_cut = 0.02

C = nothing#DoNOF.read_C(title=p.title)
n = nothing#DoNOF.read_n(title=p.title)

DoNOF.energy(bset,p,C=C,n=n,do_hfidr=false,do_m_diagnostic=true)
