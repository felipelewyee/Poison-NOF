using DoNOF

mol = """
1 2
He     0.00000000  0.00000000  -0.80565280
He     0.00000000  0.00000000  0.80565280
"""

bset,p = DoNOF.molecule(mol,"cc-pvtz",spherical=true)

p.title = "SIE4x4_6_he2+_1.5"

p.ipnof = 9

p.RI = true
p.maxit = 40

p.maxloop = 10

#DoNOF.set_ncwo(p,1)
p.h_cut = 0.025*sqrt(2)

C = nothing#DoNOF.read_C(title=p.title)
n = nothing#DoNOF.read_n(title=p.title)

DoNOF.energy(bset,p,C=C,n=n,do_hfidr=false,do_m_diagnostic=true)
